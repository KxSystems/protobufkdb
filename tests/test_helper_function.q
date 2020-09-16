// test_helper_function.q

// --------------- TEST GLOBALS --------------- //

// Define enum representing status of executing a function
.test.EXECUTION_STATUS__:`Ok`Error;
.test.EXECUTION_ERROR__:`.test.EXECUTION_STATUS__$`Error;
.test.EXECUTION_OK__:`.test.EXECUTION_STATUS__$`Ok;

/
* @brief Check if execution fails and teh returned error matches a specified message
* @param func: interface function to apply
* @param args: list of arguments to pass to the function
* @param errkind: string error kind message to expect. ex.) "Invalid scalar type"
* @return boolean
\
.test.ASSERT_ERROR:{[func; args; errkind]
  res:.[func; args; {[err] (.test.EXECUTION_ERROR__; err)}];
  $[.test.EXECUTION_ERROR__ ~ first res; 
    res[1] like errkind,"*";
    0b
  ]
 }

/
* @brief Check if comparison succeeds
* @param func: interface function to apply
* @param args: list of arguments to pass to the function
* @param target: target to compare
* @return boolean
\
.test.ASSERT_TRUE:{[func; args; target]
  .[func; args] ~ target
 }

/
* @brief Check if comparison fails
* @param func: interface function to apply
* @param args: list of arguments to pass to the function
* @param target: target to compare
* @return boolean
\
.test.ASSERT_FALSE:{[func; args; target]
  not .test.ASSERT_TRUE[func; args; target]
 }

// ------------------- END -------------------- //
