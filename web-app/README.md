# Create web app with CI/CD using terraform and ansible

## CI/CD
Here you will implement Continuous Integration and Continuous Delivery (or even Deployment). You can choose which CI tool you will use. Use Jenkins from previous exercises or existing hosted solutions. Create an application that will be connecting to a database. The application should scale depending on the usage. It should be deployed automatically from CI. Try different deployment strategies. Remember about security and backups!

* Use Jenkins any other CI/CD Tool
* Create an application which:
  * store data in database (hosted on the cloud)
  * credentials to database should be stored in secure place
  * application should work in high availability mode
  * data and traffic should be encrypted
  * data should be backed up
* Database should store user profiles and credentials
* Deploy application should be deployed on the cloud
* Application should be automatically deployed from main/master branch
  * Try different deployment strategies
* Question:
  * Two layer application? (frontend → backend → database)?


## Used libs

App -> Flask
CSS -> picocss