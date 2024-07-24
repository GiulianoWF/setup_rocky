import os
import subprocess

def run_command(cmd):
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True, shell=True)
    return result.returncode, result.stdout.strip()

thisUserName = os.environ['USER']
knownHostsFile = f"/home/{thisUserName}/.ssh/known_hosts"

# Check known hosts
return_code, _ = run_command(f"grep -q github.com {knownHostsFile}")
if not os.path.isfile(knownHostsFile) or return_code != 0:
    run_command(f"ssh-keyscan -t rsa github.com >> {knownHostsFile}")
else:
    print(f"GitHub SSH fingerprint already exists in known_hosts for {thisUserName}.")

# Check if git is installed
return_code, _ = run_command(["command", "-v", "git"])
if return_code != 0:
    run_command("apt-get update")
    run_command("apt-get install git -y")
else:
    print("Git is already installed.")

_, git_username = run_command('git config --global user.name')
if not git_username:
    git_username = input("Enter your git username: ")
    run_command(f'git config --global user.name "{git_username}"')
else:
    print("Git has a user configured.")

_, git_email = run_command('git config --global user.email')
if not git_email:
    git_email = input("Enter your git email: ")
    run_command(f'git config --global user.email "{git_email}"')
else:
    print("Git has an email configured.")

# Check GitHub authentication
_, git_auth_output = run_command('ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -T git@github.com 2>&1')
if "You've successfully authenticated" in git_auth_output:
    print("Git is already set up and authenticated.")
    exit(0)

print("\n\n\n\n\n\n\n\n\n\n\n====================== Git setup =============================\n\n\n")

if thisUserName == "root":
    sshDir = f"/{thisUserName}/.ssh"
else:
    sshDir = f"/home/{thisUserName}/.ssh"

sshKeyPath = os.path.join(sshDir, "id_ed25519")

# Check and create .ssh directory if it doesn't exist
if not os.path.exists(sshDir):
    os.mkdir(sshDir)
    os.chown(sshDir, os.getuid(), os.getgid())
    os.chmod(sshDir, 0o700)

# Generate SSH key
if not os.path.exists(f"{sshKeyPath}.pub"):
    print("This will setup the ssh key to use with git. Save the key on the default path.")
    run_command(f"ssh-keygen -t ed25519 -C {git_email} -f {sshKeyPath}")
else:
    print("SSH key already exists. Skipping key generation.")

os.chown(sshKeyPath, os.getuid(), os.getgid())
os.chown(f"{sshKeyPath}.pub", os.getuid(), os.getgid())

# Add SSH key to agent
run_command(f"sh -c eval $(ssh-agent -s) && ssh-add")

print("\n\n==========================================================================")
print("\n\nAdd the following key, including the email, to your git ssh (https://github.com/settings/keys):\n\n")
with open(f"{sshKeyPath}.pub", 'r') as key_file:
    key = key_file.read()
print(key)
print("\n\n==========================================================================")

# ASCII Art
print("""
         .----------------.   
        | .--------------. |  
        | |      _       | |  
        | |     | |      | |  
        | |     | |      | |  
        | |     | |      | |  
        | |     |_|      | |
        | |      _       | |    
        | |     (_)      | |  
        | '--------------' |  
         '----------------' 
    """)

# Wait for user to add SSH key to GitHub
while True:
    _, git_auth_output = run_command('ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -T git@github.com 2>&1')
    if "You've successfully authenticated" in git_auth_output:
        print("Git set up and authenticated.")
        break
    else:
        print(key)
        input("\n\nWaiting for you to add the keys to github...\n(Press a key when done)\n")
        

exit(0)


