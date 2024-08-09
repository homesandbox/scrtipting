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
  
  shutil.copytree(src_path, dst_path)
      
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
    logger.exception(e)
    sys.exit(1)
