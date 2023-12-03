#!/bin/bash

#Definimos el Internal Field Separator para que el bucle while lea el fichero paquetes.txt correctamente
IFS=":"

#Creamos dos arrays, uno para los paquetes y otro para las acciones
packages=()
actions=()

#Leemos el fichero paquetes.txt y guardamos los paquetes y las acciones en los arrays
while read -r package action
do
    #Si no se ha especificado una acción, se le asigna 'status' por defecto
    if [ -z "$action" ];
    then
        echo "El paquete '$package' no tiene una acción por defecto, se le asignará 'status'."
        action="status"
    fi
    
    #Añadimos los paquetes y las acciones a los arrays
    packages+=( "$package" )
    actions+=( "$action" )
done < paquetes.txt

#Asignamos a la variable size el tamaño del array para poder recorrer los dos en un solo for.
size="${#packages[@]}"

#Recorremos los arrays y realizamos las acciones correspondientes
for ((i=0; i<size; i++));
do
echo
    #Si la acción es status, comprobamos si el servicio está activo	
    if [ "${actions[$i]}" == "status" ];
    then
        systemctl status "${packages[$i]}" 2> /dev/null

        #Si el servicio no existe, se muestra un mensaje de error y se continua con el siguiente paquete
        if [ $? -ne 0 ];
        then
            echo "El servicio '${packages[$i]}' no existe."
            continue
        fi
    
    #Si la acción es add, se instala el paquete
    elif [ "${actions[$i]}" == "add" ];
    then
        apt install -y "${packages[$i]}" &> /dev/null

    #Si la acción es remove, se desinstala el paquete
    elif [ "${actions[$i]}" == "remove" ];
    then
        apt remove -y "${packages[$i]}" &> /dev/null

    #Si la acción no es ninguna de las anteriores, se muestra un mensaje de error
    else
        echo "La opción: '${actions[$i]}' es incorrecta."
    fi

    #Si el código de error es distinto de 0, se muestra un mensaje de error para que se compruebe el fichero paquetes.txt
    if [ $? -ne 0 ];
    then
        echo "No se ha podido realizar la acción '${actions[$i]}' sobre el paquete '${packages[$i]}'."
        echo "Comprueba que el nombre del paquete es correcto."
    fi
done