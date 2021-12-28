The current method to make pipelines has the following steps:

We set the varibales in variables.tf file and ran the tf script with s3 backend code commented.
<ul>The following commands are executed. </ul>
<li> terraform init </li>
<li> terraform plan </li>
<li> terraform apply </li>

Then we un-comment the s3 backend code and set the variable name in backend-state.tf file. (Make sure to have the same name for bucket which was set in variables.tf or else it gives error). After that run this command:

<li> terraform init --backend-config="backend file path"</li>
