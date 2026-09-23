"""Untrusted capture metadata never becomes an arbitrary ffconcat input."""
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import capture_balance_pacing as capture

class CaptureSecurityTests(unittest.TestCase):
    def test_rejects_unsafe_metadata_before_encoder(self):
        bad = [
            {'file': '../secret.png'}, {'file': '/tmp/secret.png'},
            {'file': "00000.png'\nfile '/private/file"}, {'file': 'https://example.com/a.png'},
            {'day': '../../outside'}, {'day': True}, {'day': 8},
            {'wall_msec': float('inf')}, {'wall_msec': -1},
        ]
        for changes in bad:
            with self.subTest(changes=changes), tempfile.TemporaryDirectory() as folder:
                root=Path(folder).resolve();(root/'results/pace').mkdir(parents=True)
                (root/'results/pace/00000.png').write_bytes(b'synthetic')
                row={'file':'00000.png','day':1,'wall_msec':0};row.update(changes)
                (root/'results/b8-test.json').write_text(json.dumps({'capture_times':[row]}))
                with patch.object(capture.subprocess,'run') as run:
                    with self.assertRaises(ValueError):capture.encode(root)
                    run.assert_not_called()

    def test_rejects_symlink_and_reversed_timing(self):
        with tempfile.TemporaryDirectory() as folder:
            root=Path(folder).resolve();(root/'results/pace').mkdir(parents=True)
            (root/'outside.png').write_bytes(b'synthetic')
            frame=root/'results/pace/00000.png';frame.symlink_to(root/'outside.png')
            row={'file':'00000.png','day':1,'wall_msec':2}
            with self.assertRaises(ValueError):capture.validated_captures(root,[row])
            frame.unlink();frame.write_bytes(b'synthetic')
            with self.assertRaises(ValueError):capture.validated_captures(root,[row,dict(row,wall_msec=1)])

    def test_valid_files_use_safe_relative_concat_paths(self):
        with tempfile.TemporaryDirectory(prefix="capture quote ' ") as folder:
            root=Path(folder).resolve();(root/'results/pace').mkdir(parents=True)
            for name in ['00000.png','00001.png']:(root/'results/pace'/name).write_bytes(b'synthetic')
            data={'strategy':'lean','setup':'synthetic','capture_times':[
                {'file':'00000.png','day':1,'wall_msec':100},
                {'file':'00001.png','day':1,'wall_msec':1100}]}
            (root/'results/b8-test.json').write_text(json.dumps(data))
            with patch.object(capture.subprocess,'run') as run:
                capture.encode(root)
                args=run.call_args.args[0]
                self.assertEqual(args[args.index('-safe')+1],'1')
            self.assertEqual((root/'day1-wall-time.txt').read_text(),
                "file 'results/pace/00000.png'\nduration 1.0\nfile 'results/pace/00001.png'\n")

if __name__=='__main__':unittest.main()
