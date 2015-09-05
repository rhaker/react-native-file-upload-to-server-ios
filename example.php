<?
// EXAMPLE TO HANDLE FILE UPLOAD ON THE SERVER

// To see the complete file use var_dump
echo "Files: ";
var_dump($_FILES);

// To get the field metadata with a key-value of "parameter1:value1"
$uploadField1 = $_POST['parameter1'];

?>
