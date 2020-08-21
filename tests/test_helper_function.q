// test_helper_function.q

// --------------- TEST GLOBALS --------------- //

// Define enum representing status of executing a function
EXECUTION_STATUS__:`Ok`Error;
EXECUTION_ERROR__:`EXECUTION_STATUS__$`Error;
EXECUTION_OK__:`EXECUTION_STATUS__$`Ok;

/
* @brief Check if execution fails
* @param func: interface function to apply
* @param args: list of arguments to pass to the function
* @return boolean
\
.test.ASSERT_ERROR:{[func; args]
  res:.[func; args; {EXECUTION_ERROR__}];
  $[res ~ EXECUTION_ERROR__; 1b; 0b]
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
