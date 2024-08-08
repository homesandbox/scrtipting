import argparse
import sys
import traceback
from git import Repo, GitCommandError

def main():
  # Set up argument parsing
  parser = argparse.ArgumentParser(description='Tag a specific commit in a Git repository.')
  parser.add_argument('tag', help='The tag name to create.')
  parser.add_argument('commit', help='The commit to tag.')
  args = parser.parse_args()

  try:
    # Open the repository
    repo = Repo('.')

    # Tag the commit
    tag_name = args.tag
    commit_sha = args.commit
    tag_message = tag_name

    if tag_name in repo.tags:
      print(f'Tag {tag_name} already exists.')
      sys.exit(1)

    # Create the tag
    repo.create_tag(tag_name, commit_sha, message=tag_message)
    print(f'Tag {tag_name} created at {commit_sha}.')

    # Push the tag
    origin = repo.remote(name='origin')
    origin.push(tags=True)
    print(f'Tag {tag_name} pushed to remote.')

  except GitCommandError as e:
    print(f'Git command error: {e}')
    sys.exit(1)
  except Exception as e:
    # Print detailed traceback for debugging
    print('An unexpected error occurred:')
    traceback.print_exc()
    sys.exit(1)

if __name__ == '__main__':
  main()
