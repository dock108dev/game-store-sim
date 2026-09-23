"""Focused wrapper checks; no engine, artwork rebuild or review saves required."""

import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import validate


class ValidationRunnerTests(unittest.TestCase):
    def test_engine_failures_retain_exit_and_log(self):
        for status, message in (
            (1, 'process failed'),
            (0, 'ERROR: first line failure\n'),
            (0, 'engine banner\nERROR: later failure\n'),
            (0, 'SCRIPT ERROR: script failed\n'),
        ):
            with self.subTest(status=status, message=message), tempfile.TemporaryDirectory() as folder:
                output = Path(folder)

                def execute(command, **kwargs):
                    kwargs['stdout'].write(message)
                    return subprocess.CompletedProcess(command, status)

                with patch.object(validate.subprocess, 'run', side_effect=execute):
                    with self.assertRaises(RuntimeError):
                        validate.run_check(output, output, 'probe', ['--headless'])
                self.assertEqual((output / 'probe.log').read_text(), message)
                self.assertEqual(json.loads((output / 'probe-exit.json').read_text()), {'exit': status})

    def test_abnormal_process_attempts_retain_safe_status(self):
        for error, status in [
            (subprocess.TimeoutExpired(['private-command'], 900), 'timeout'),
            (FileNotFoundError('private-path'), 'launch_failed'),
            (KeyboardInterrupt(), 'interrupted'),
        ]:
            with self.subTest(status=status), tempfile.TemporaryDirectory() as folder:
                output = Path(folder)
                def execute(command, **kwargs):
                    kwargs['stdout'].write('partial log\n')
                    raise error
                with patch.object(validate.subprocess, 'run', side_effect=execute):
                    with self.assertRaises(type(error)):
                        validate.run_check(output, output, 'probe', [])
                self.assertEqual(json.loads((output / 'probe-exit.json').read_text()),
                                 {'exit': None, 'status': status})
                self.assertEqual((output / 'probe.log').read_text(), 'partial log\n')

    def test_basic_selection_is_headless_and_excludes_full_week(self):
        with patch.object(validate, 'run_check') as run:
            validate.run_basic_checks(Path('/synthetic/project'), Path('/synthetic/output'))
        names = [call.args[2] for call in run.call_args_list]
        self.assertEqual(names, ['import', 'week-state', 'week-regressions', 'ssot',
                                 'security', 'storage', 'price-request',
                                 'presentation-headless', 'restart-flow'])
        self.assertTrue(all('--headless' in call.args[3] for call in run.call_args_list))

    def test_warning_alone_is_not_an_error(self):
        with tempfile.TemporaryDirectory() as folder:
            def execute(command, **kwargs):
                kwargs['stdout'].write('WARNING: retained warning\n')
                return subprocess.CompletedProcess(command, 0)

            with patch.object(validate.subprocess, 'run', side_effect=execute):
                validate.run_check(Path(folder), Path(folder), 'probe', [])

    def test_isolation_preserves_source_and_excludes_generated_files(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            source = root / 'source'
            source.mkdir()
            settings = (
                'config/use_custom_user_dir=true\n'
                f'config/custom_user_dir_name="{validate.REVIEW_NAMESPACE}"\n'
            )
            (source / 'project.godot').write_text(settings)
            for name in validate.EXCLUDED:
                (source / name).mkdir()
                (source / name / 'retained').write_text('untouched')
            with patch.object(validate.tempfile, 'mkdtemp', return_value=str(root / 'isolated')):
                work = validate.isolate_project(source)
            self.assertEqual((source / 'project.godot').read_text(), settings)
            self.assertIn('config/custom_user_dir_name="isolated"', (work / 'project.godot').read_text())
            self.assertEqual(list((work / 'evidence').iterdir()), [])
            self.assertFalse((work / '.godot').exists())
            self.assertFalse((work / '__pycache__').exists())

    def test_changed_namespace_or_disabled_custom_directory_stops_isolation(self):
        for settings in (
            'config/use_custom_user_dir=true\nconfig/custom_user_dir_name="unexpected"\n',
            'config/use_custom_user_dir=true\nconfig/custom_user_dir_name="game-sim-first-week-dev-v6"\n',
            'config/use_custom_user_dir=true\nconfig/custom_user_dir_name="game-sim-first-week-dev-v7"\n',
            'config/use_custom_user_dir=true\nconfig/custom_user_dir_name="game-sim-first-week-dev-v8"\n',
            'config/use_custom_user_dir=true\nconfig/custom_user_dir_name="game-sim-first-week-dev-v9"\n',
            f'config/custom_user_dir_name="{validate.REVIEW_NAMESPACE}"\n',
            'config/use_custom_user_dir=true\nconfig/custom_user_dir_name="game-sim-r5-review-isolated"\n',
            f'config/use_custom_user_dir=true\nconfig/custom_user_dir_name="{validate.REVIEW_NAMESPACE}"\nconfig/custom_user_dir_name="owner"\n',
            f'config/use_custom_user_dir=true\nconfig/use_custom_user_dir=false\nconfig/custom_user_dir_name="{validate.REVIEW_NAMESPACE}"\n',
        ):
            with self.subTest(settings=settings), tempfile.TemporaryDirectory() as folder:
                root = Path(folder)
                source = root / 'source'
                source.mkdir()
                (source / 'project.godot').write_text(settings)
                with patch.object(validate.tempfile, 'mkdtemp', return_value=str(root / 'isolated')):
                    with self.assertRaises(RuntimeError):
                        validate.isolate_project(source)
                self.assertEqual((source / 'project.godot').read_text(), settings)


if __name__ == '__main__':
    unittest.main()
