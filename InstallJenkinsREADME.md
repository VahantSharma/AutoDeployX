# README: Jenkins Installer Script
This script automates the process of downloading and installing the latest Long-Term Support (LTS) version of Jenkins on your system. It also checks for Java, a required dependency, and installs it if not already available. The script supports Linux, macOS, and Windows systems.

---

## How it Works
The script consists of multiple functions that work together to detect your operating system, fetch the latest version of Jenkins, and install it appropriately. Here's a simple breakdown of the steps:

---

### 1. Greet the User

```bash
"Good Morning, Pineapple. Looking very good, very nice."
```

### 2.Fetch Latest Jenkins LTS Version
- (Used LinuxArticle website for this)
- Fetches the latest version of Jenkins(LTS).
- If it can't fetch a valid version, the script stops and informs the user.
- Below, stores the API response and then used advanced search option of grep(-E flag)


```bash
    API_RESPONSE=$(curl -s https://updates.jenkins.io/current/latestCore.txt)

    LTS_VERSION=$(echo "$API_RESPONSE" | grep -Eo '^[0-9]+\.[0-9]+\.[0-9]+')
    
    if [ -z "$LTS_VERSION" ]; then
        echo "Error fetching the LTS version or invalid version received. Exiting."
        exit 1
    fi
    # -z flag checks kahin variable empty string toh nhi
```

---

### 3.Detect Your Operating System

- Reference from AskUbuntu(didnt know what was Darwin,CYGWIN, MINGW and MSYS but learnt bout them)
- Automatically determines the OS running on your computer:
    - Linux
    - macOS
    - Windows
- uname command returns all details about kernel whereas ismein -s  flag lgane sirf naam return kr deta hai  

```bash
detect_os() {
    echo "Detecting operating system..."
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)     OS=Linux ;;
        Darwin*)    OS=Mac ;;
        CYGWIN*|MINGW*|MSYS*) OS=Windows ;;
        *)          OS="UNKNOWN:${unameOut}" ;;
    esac
    echo "Operating system detected: $OS"
}
```

---

### 4. Check for Java Installation

- (Learnt about -v flag and /dev/null i have used before)
- Jenkins requires Java to run.
- If Java isn't installed, the script installs Java 17 based on your operating system and package manager
- checks if java path file exists , then discards any output/error using /dev/null and prints ki download java
- else switch case mein chali jaati hai and checks for the ibnstalled package manager
- Checking of package manager se distro detect kr leta hai.

```bash
if ! command -v java >/dev/null 2>&1; then

if command -v apt >/dev/null 2>&1; then
                    sudo apt update && sudo apt install -y openjdk-17-jdk
                elif command -v yum >/dev/null 2>&1; then
                    sudo yum install -y java-17-openjdk-devel
                elif command -v pacman >/dev/null 2>&1; then
                    sudo pacman -Syu --noconfirm openjdk17
                else
                    echo "No supported package manager detected. Please install Java manually."
                    exit 1
                fi

```

---

### 5. Install Jenkins

(Reference from AskUbuntu)

- (Learnt where the usr/share/key/keyrings mein public keys store hoti hai etc etc)

After detecting the OS and ensuring Java is installed, the script installs Jenkins:

- For Linux: It uses apt, yum, or pacman depending on your Linux distribution.
- For macOS: It uses Homebrew to install Jenkins.
- For Windows: It uses Chocolatey (a package manager for Windows).


```bash
if command -v apt >/dev/null 2>&1; then
        echo "Installing Jenkins on Debian/Ubuntu..."
        sudo apt-get update
        curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
        echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian/ stable main" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y jenkins="$LTS_VERSION"
        
 ```
 
 --- 
 
 ## How to Use This Script
 
### 1. Prerequisites

 Ensure your system has the following:
- Linux, macOS, or Windows
- Package Manager:
    - Linux: apt, yum, or pacman
    - macOS: Homebrew
    - Windows: Chocolatey

### 2. Run the Script
- Open a terminal or command prompt.
- Copy the script into a file, e.g.,  install_jenkins.sh.
- Run the following commands:

```bash
chmod +x install_jenkins.sh
./install_jenkins.sh
```

### 3. Follow the Instructions
- The script will guide you step-by-step:
    - Detect your OS.
    - Fetch the latest Jenkins version.
    - Install Java if needed.
    - Install Jenkins for your OS.

---

## Script Overview for Beginners

(Used GPT for this )

This section provides a simple breakdown of what each function in the script does, making it easy to understand even for those new to scripting.  

| **Function Name**   | **Purpose**                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| `lts_version`        | Fetches the latest stable Jenkins version.                                 |
| `detect_os`          | Detects your operating system (Linux, macOS, or Windows).                 |
| `install_java`       | Installs Java 17 if not already installed.                                 |
| `install_linux`      | Installs Jenkins on Linux systems using available package managers.        |
| `install_mac`        | Installs Jenkins on macOS using Homebrew.                                  |
| `install_windows`    | Installs Jenkins on Windows using Chocolatey.                              |
| `install_jenkins`    | Calls the appropriate installation function based on your operating system.|
| `main`               | Orchestrates the entire process: detects OS, fetches the Jenkins version, and installs Jenkins. |
