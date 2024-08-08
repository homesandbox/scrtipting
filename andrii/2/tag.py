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
    try:
      repo = Repo('.')
      print('Repository opened successfully.')
    except Exception as e:
      print('Error: Could not open the repository.')
      print(f'Detailed error: {e}')
      sys.exit(1)

    # Tag the commit
    tag_name = args.tag
    commit_sha = args.commit
    tag_message = tag_name

    try:
      if tag_name in repo.tags:
        print(f'Tag {tag_name} already exists.')
        sys.exit(1)

      repo.create_tag(tag_name, commit_sha, message=tag_message)
      print(f'Tag {tag_name} created at {commit_sha}.')
    except GitCommandError as e:
      print('Error: Could not create the tag.')
      print(f'Detailed error: {e}')
      sys.exit(1)
    except Exception as e:
      print('An unexpected error occurred while creating the tag:')
      print(f'Detailed error: {e}')
      sys.exit(1)

    # Push the tag
    try:
      origin = repo.remote(name='origin')
      origin.push(tags=True)
      print(f'Tag {tag_name} pushed to remote.')
    except GitCommandError as e:
      if 'Could not read from remote repository' in str(e):
        print('Error: Could not read from remote repository. Please check your remote URL and authentication settings.')
      else:
        print('Error: Could not push the tag to the remote repository.')
        print(f'Detailed error: {e}')
      sys.exit(1)
    except Exception as e:
      print('An unexpected error occurred while pushing the tag:')
      print(f'Detailed error: {e}')
      sys.exit(1)

  except Exception as e:
    # Print detailed traceback for debugging
    print('An unexpected error occurred:')
    traceback.print_exc()
    sys.exit(1)

if __name__ == '__main__':
  main()
