# Storyline: Write a program that lists all registered services (where stopped or running).
# Provide a prompt that allows the user to select if they want to view all services, running or stopped services.
# Check that the user-specified only 'all', 'stopped', or 'running' as a value.
# Send the user back to the prompt if they entered an invalid value. Otherwise, print the results.
# Provide an option to 'quit' the program.


function select_service() {
    cls

    # Create array with status
    $serviceStatus = @('[a]ll','[s]topped','[r]unning')

    $serviceStatus

    # Prompt the user for the status to view or quit
    $readStatus = read-host -Prompt "Please enter THE FIRST LETTER of a status from the list above to view the proper services or 'q' to quit the program"

    # Check if the user wants to quit
    if ($readStatus -match "^[qQ]$") {

        #Stop executing the program and close the script
        break

    }

    service_check -serviceToSearch $readStatus
}

function service_check() {

    # Status must match first letter of input
    if ($readStatus -match "^[aA]$") {
    
        write-host -BackgroundColor Green -ForegroundColor white "Please wait, it may take a few moments to retrieve the services."
        sleep 2
    
        # Get all services
        Get-Service

    } elseif ($readStatus -match "^[sS]$") {
       
        write-host -BackgroundColor Green -ForegroundColor white "Please wait, it may take a few moments to retrieve the services."
        sleep 2

        # Get Stopped services
        Get-Service | Where { $_.Status -eq "Stopped" }

    } elseif ($readStatus -match "^[rR]$") {
        
        
        write-host -BackgroundColor Green -ForegroundColor white "Please wait, it may take a few moments to retrieve the services."
        sleep 2

        # Get running services
        Get-Service | Where { $_.Status -eq "Running" }

    } else {

        write-host -BackgroundColor Red -ForegroundColor white "The status specified doesn't exist."

        sleep 2

        select_service


    } # end else
        
}

select_service