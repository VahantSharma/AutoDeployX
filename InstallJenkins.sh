#!/bin/bash

set -e

echo "Good Morning, Pineapple."
echo "Looking very good, very nice."

# Function LTS version grep krlega
lts_version() {
    echo "Fetching the latest Jenkins LTS version..."
    API_RESPONSE=$(curl -s https://updates.jenkins.io/current/latestCore.txt)

    # Checks API version valid hai
    # Referenced AskUbuntu -E0 flags and advance grep knowledge ke liye
    LTS_VERSION=$(echo "$API_RESPONSE" | grep -Eo '^[0-9]+\.[0-9]+\.[0-9]+')

    if [ -z "$LTS_VERSION" ]; then
        echo "Error fetching the LTS version or invalid version received. Exiting."
        exit 1
    fi

    echo "Latest Jenkins LTS Version: $LTS_VERSION"
}

# OS detector hai
detect_os() {
    echo "Detecting operating system..."
    unameOut="$(uname -s)"  
    case "${unameOut}" in
        Linux*)     OS=Linux ;;
        Darwin*)    OS=Mac ;; 
        CYGWIN*|MINGW*|MSYS*) OS=Windows ;; #posix environments jissse unix like functionality
        *)          OS="UNKNOWN:${unameOut}" ;;
    esac
    echo "Operating system detected: $OS"
}

# 
install_java() {
    echo "Checking for Java installation..."
    if ! command -v java >/dev/null 2>&1; then
        echo "Java not found. Installing Java 17..."
        case "$OS" in
            Linux)
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
                ;;
            Mac)
                if command -v brew >/dev/null 2>&1; then
                    brew install openjdk@17
                else
                    echo "Homebrew not found. Please install Homebrew and Java manually."
                    exit 1
                fi
                ;;
            Windows)
                echo "Please install Java manually or use Chocolatey."
                exit 1
                ;;
            *)
                echo "Unsupported OS for Java installation. Exiting..."
                exit 1
                ;;
        esac
    else
        echo "Java is already installed."
    fi
}

# Linux installer
install_linux() {
    echo "Detected Linux. Installing Jenkins..."
    install_java

    if command -v apt >/dev/null 2>&1; then
        echo "Installing Jenkins on Debian/Ubuntu..."
        sudo apt-get update
        curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
        echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian/ stable main" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y jenkins="$LTS_VERSION"
    elif command -v yum >/dev/null 2>&1; then
        echo "Installing Jenkins on RHEL/CentOS/Fedora..."
        sudo yum install -y java-17-openjdk-devel
        curl -fsSL https://pkg.jenkins.io/redhat/jenkins.io.key | sudo tee /etc/yum.repos.d/jenkins.repo
        sudo yum install -y jenkins-"$LTS_VERSION"
    elif command -v pacman >/dev/null 2>&1; then
        echo "Installing Jenkins on Arch Linux..."
        sudo pacman -Syu --noconfirm jenkins
    else
        echo "Unsupported package manager. Install Jenkins manually."
        exit 1
    fi

    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    echo "Jenkins installed successfully! Access it at http://localhost:8080"
}

# macOS installer
install_mac() {
    echo "Detected macOS. Installing Jenkins..."
    install_java

    if command -v brew >/dev/null 2>&1; then
        brew update
        brew tap jenkinsci/jenkins
        brew install jenkins-lts
        brew services start jenkins-lts
        echo "Jenkins installed successfully! Access it at http://localhost:8080"
    else
        echo "Homebrew not found. Please install Homebrew and Jenkins manually."
        exit 1
    fi
}

# window ins
install_windows() {
    echo "Detected Windows. Installing Jenkins..."
    install_java

    if command -v choco >/dev/null 2>&1; then
        choco install jenkins --version="$LTS_VERSION" -y
        echo "Jenkins installed successfully! You can now run Jenkins from the Start menu."
    else
        echo "Chocolatey not found. Please install Chocolatey and Jenkins manually."
        exit 1
    fi
}

# install jenkins based on OS
install_jenkins() {
    case "$OS" in
        Linux) install_linux ;;
        Mac) install_mac ;;
        Windows) install_windows ;;
        *) echo "Unsupported OS detected: $OS. Exiting..."; exit 1 ;;
    esac
}

# Main function to orchestrate the process
main() {
    detect_os        
    lts_version      
    install_jenkins  

# Run the main function
main
