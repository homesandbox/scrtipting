import shutil
import sys
import logging
from pathlib import Path

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger()

def copy_tree(src, dst):
  src_path = Path(src)
  dst_path = Path(dst)

  if not src_path.is_dir():
    raise ValueError(f"Source path '{src}' is not a directory")

  # Ensure destination directory exists
  dst_path.mkdir(parents=True, exist_ok=True)

  for item in src_path.iterdir():
    if item.is_dir():
      new_dst = dst_path / item.name
      copy_tree(item, new_dst)
    else:
      shutil.copy2(item, dst_path / item.name)

if __name__ == '__main__':
  if len(sys.argv) != 3:
    logger.error('Usage: python script.py <source_directory> <destination_directory>')
    sys.exit(1)

  source_dir = sys.argv[1]
  destination_dir = sys.argv[2]

  try:
    copy_tree(source_dir, destination_dir)
    logger.info(f"Files copied from '{source_dir}' to '{destination_dir}' successfully.")
  except Exception as e:
    logger.error('An error occurred during file copying.')
    logger.exception(e)  # Logs the full traceback for debugging
    sys.exit(1)
