*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.FTP
Library             RPA.Archive


*** Variables ***
${id-body}=         id-body-
${pdf_folder}       ${CURDIR}${/}pdf_files


*** Tasks ***
Orders robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download the orders file
    Go through the orders and make PDF from receipts
    Create a Zip File of the Receipts
    [Teardown]    Close the browser


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Wait Until Page Contains Element    id:root

Give up all your constitutional rights!
    Click Button    OK

Download the orders file
    RPA.HTTP.Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}

Go through the orders and make PDF from receipts
    ${robot_orders}=    Read table from CSV    orders.csv    header=True
    FOR    ${robot_order}    IN    @{robot_orders}
        Fill and submit the form for one robot    ${robot_order}
    END

Store the receipt as a PDF file
    [Arguments]    ${ORDER_NUMBER}
    Wait Until Page Contains Element    id:receipt
    ${order_receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_receipt_html}    ${pdf_folder}${/}${ORDER_NUMBER}.pdf
    RETURN    ${pdf_folder}${/}${ORDER_NUMBER}.pdf

Take a screenshot of the robot
    [Arguments]    ${ORDER_NUMBER}
    Screenshot    id:robot-preview    ${OUTPUT_DIR}${/}${ORDER_NUMBER}.png
    RETURN    ${OUTPUT_DIR}${/}${ORDER_NUMBER}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${IMG_FILE}    ${PDF_FILE}
    Open Pdf    ${PDF_FILE}
    ${robotPNG}=    Create List    ${IMG_FILE}
    Add Files To Pdf    ${robotPNG}    ${PDF_FILE}    ${True}
    Close Pdf    ${PDF_FILE}

Create a Zip File of the Receipts
    Archive Folder With ZIP    ${pdf_folder}    ${OUTPUT_DIR}${/}pdf_archive.zip    recursive=True    include=*.pdf

Fill and submit the form for one robot
    [Arguments]    ${robot_order}
    Give up all your constitutional rights!
    Select From List By Value    head    ${robot_order}[Head]
    Select Radio Button    body    ${id-body}${robot_order}[Body]
    Input Text    address    ${robot_order}[Address]
    Input Text    css:input[placeholder="Enter the part number for the legs"]    ${robot_order}[Legs]
    Click Button    preview
    Wait Until Keyword Succeeds    6x    0.5    Order
    ${pdf}=    Store the receipt as a PDF file    ORDER_NUMBER=${robot_order}[Order number]
    ${screenshot}=    Take a screenshot of the robot    ORDER_NUMBER=${robot_order}[Order number]
    Embed the robot screenshot to the receipt PDF file    IMG_FILE=${screenshot}    PDF_FILE=${pdf}
    Click Button    order-another

Order
    Click Button    order
    Page Should Contain Element    id:receipt

Close the browser
    Close Browser

Minimal task
    Log    Done.
