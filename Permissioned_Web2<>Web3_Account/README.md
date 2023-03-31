# Permissioned Web2 <> Web3 Account
The system create public and private key pair for each user in a microservice on AWS Lambda and the encrypted private key is custodied on AWS Secrets Manager. The system use Nitro Enclaves as a secure compute environment for low-level blockchain tasks such as signing transactions.

## Architecture
![Architecture](https://github.com/chlee114hk/xalts_assignment/blob/main/Permissioned_Web2%3C%3EWeb3_Account/web2_to_web3_account_system_architecture.drawio.png)

## Flow of public and private key pair creation
![Architecture](https://github.com/chlee114hk/xalts_assignment/blob/main/Permissioned_Web2%3C%3EWeb3_Account/sequence_diagram_new_account.drawio.png)

1. A valid Public and private key pair is generated in a microservice on AWS Lambda upon a new user account created. This service can be built using `w3.eth.account.create()` command using library web3.py or other similar library.

2. Encrypt the private key using the KMS key. The Lambda function is only allowed to run `encrypt` function on the KMS key by setting KMS key policy.

3. Persist the encrypted key in AWS Secrets Manager. The private key stored in Secrets Manager will be encrypted one more time with a different KMS key.

4. Create a relation record of secret id, public key and user id in RMDB.

## Signing flow
![Architecture](https://github.com/chlee114hk/xalts_assignment/blob/main/Permissioned_Web2%3C%3EWeb3_Account/sequence_diagram_sign_transaction.drawio.png)

1. A transaction signing microservice with `sign_transaction` function is built for signing transaction for the portal users. The function sends a request with transaction payload data to the web server on parent EC2 instance containing Nitro Enclaves.

2. The double encrypted private key is downloaded from AWS Secrets Manager and decrypted the first time based on the EC2 instance role.

3. The single encrypted private key is then passed to Nitro Enclaves together with transaction payload.

4. Nitro Enclaves uses the cryptographic attestation feature to decrypt the encrypted private key to plaintext version. Due to the cryptographic attestation feature and our customized KMS key policy, we can run the last decryption step from within the enclave. No other component (such as the EC2 instance) can get access to the plaintext version of the key.

5. The key is used to sign the transaction inside the enclave. The signed transaction is returned to web server in the parent EC2 instance. The plaintext private key is then deleted from inside the enclave.

6. The transaction signing microservice get the signed transaction and send the  transaction to Ethereum node.

## Security 
1. Only secret id is store in database.
2. Private key stored in AWS Secrets Manager is double encrypted.
3. Private key can only possible decrypted by the server running within Nitro Enclaves and finish the required transaction signing inside. There is no way to get access the plaintext private keys even for the developers who can access to the ec2 instance given proper policy setting.

## Limitation
1. This system can only be possible to implemented using AWS due to the necessary conponent of AWS Nitro Enclaves.
