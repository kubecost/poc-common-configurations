# Custom Assets

This is a work in progress, please let us know how you would like to use this type of function within Kubecost.


1. Create a new object store (S3, Azure Storage Account blob, etc)
1. Create a folder structure similar to: `daily/csv/20230401-20230430/`
1. Kubecost only processes the most recently modified file
1. Data in the file should be cumulative data for the entire month. That is, the final file of the month will have data for the entire month.
1. In the file, Kubecost looks for the most recent 48 hours. ?