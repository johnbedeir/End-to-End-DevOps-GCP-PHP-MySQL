Yes, you can automate the process of storing secrets in Jenkins credentials using scripts. If Jenkins is deployed on a cluster, you can use the Jenkins CLI or Jenkins REST API to manage credentials programmatically.

Here’s an example of how you can achieve this using a shell script and Jenkins CLI. Ensure that you have Jenkins CLI (`jenkins-cli.jar`) and the necessary permissions set up for your Jenkins instance.

### Prerequisites

1. **Jenkins CLI**: Download the `jenkins-cli.jar` from your Jenkins instance, typically available at `http://your-jenkins-url/jnlpJars/jenkins-cli.jar`.

2. **Jenkins API Token**: Generate an API token for your Jenkins user under **Manage Jenkins > Manage Users > Your User > Configure > API Token**.

3. **Java**: Ensure Java is installed on the machine where you will run the script.

### Example Shell Script

```sh
#!/bin/bash

# Jenkins details
JENKINS_URL="http://your-jenkins-url"
JENKINS_USER="your-jenkins-username"
JENKINS_API_TOKEN="your-jenkins-api-token"
JENKINS_CLI_JAR="/path/to/jenkins-cli.jar"

# Function to create or update a Jenkins secret text credential
create_secret() {
    local secret_id="$1"
    local secret_value="$2"
    local secret_description="$3"

    # Create the XML payload for the credential
    local xml_payload="<com.cloudbees.plugins.credentials.impl.StringCredentialsImpl>
        <scope>GLOBAL</scope>
        <id>${secret_id}</id>
        <description>${secret_description}</description>
        <secret>${secret_value}</secret>
    </com.cloudbees.plugins.credentials.impl.StringCredentialsImpl>"

    # Save the XML payload to a temporary file
    local tmp_file=$(mktemp)
    echo "${xml_payload}" > "${tmp_file}"

    # Create or update the credential using Jenkins CLI
    java -jar "${JENKINS_CLI_JAR}" -s "${JENKINS_URL}" -auth "${JENKINS_USER}:${JENKINS_API_TOKEN}" create-credentials-by-xml system::system::jenkins _ < "${tmp_file}"

    if [ $? -eq 0 ]; then
        echo "Secret ${secret_id} set successfully."
    else
        echo "Failed to set secret ${secret_id}."
        exit 1
    fi

    # Clean up temporary file
    rm -f "${tmp_file}"
}

# Call the function with each secret
create_secret "GCP_CREDENTIALS" "${gcp_credentials}" "GCP credentials"
create_secret "GCP_PROJECT" "${project_id}" "GCP project ID"
create_secret "CLUSTER_NAME" "${cluster_name}" "Cluster name"
create_secret "ZONE" "${zone}" "GCP zone"
create_secret "APP_GCR_REPOSITORY" "${app_repo_name}" "App GCR repository"
create_secret "JOB_GCR_REPOSITORY" "${db_repo_name}" "Job GCR repository"
```

### Explanation

1. **XML Payload**: The script creates an XML payload for each credential, which is used by the Jenkins CLI to create or update the credential.

2. **Temporary File**: The XML payload is written to a temporary file, which is then passed to the Jenkins CLI command.

3. **Jenkins CLI Command**: The `create-credentials-by-xml` command is used to create or update the credential in Jenkins.

### Running the Script

Make sure to replace the placeholder values (e.g., `your-jenkins-url`, `your-jenkins-username`, `your-jenkins-api-token`, etc.) with your actual Jenkins details. Save the script to a file, make it executable, and run it.

```sh
chmod +x your-script.sh
./your-script.sh
```

### Notes

- Ensure the Jenkins user has the necessary permissions to manage credentials.
- This script handles only string credentials. If you need to handle other types of credentials (e.g., username/password, SSH keys), the XML payload will need to be adjusted accordingly.

By using this approach, you can automate the process of managing Jenkins credentials, similar to how you manage GitHub secrets in your other project.
