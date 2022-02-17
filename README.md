# Wbscraping
Poryectos en los que se ha implementado los pasos en el README

UNIVERSIDADJAVERIANA - CERTIFICADOS LABORALES
José Rendón, Oscar Hurtado

Solución
- Fila 62 del excel
- link:
https://cea.javeriana.edu.co/academia/departamento-economia/profesores-planta
-este es el xpath de los nombres de los profesores 
//*[@id="dircom-pw-boton-imagen-texto-contenedor-contenido"]/div[1]/a/text()').getall()

Segunda tarea: Ejectuar los comandos del docker file
Luego dentro dela carpeta external sources(dentro de projects)
 en vez de sisben metemos el projecto que hemos hechohasta
 el momento

Para generar el encarpetado dentro de este projecto: scrapy startproject scrapyBuscadosJusticia

URL DEL SERVICIO: http://localhost:80/crawl.json

scrapyrt -i 0.0.0.0 -p 8080

//Lo que se manda en el body del requesttipo post(raw)
{            "jsonUserData": 
"{\"rowId\":1,\"identificationType\":\"3\",\"identityNumber\":\"15348187\"}",
            "spider_name": "sisben",            "start_requests": "True"       

 }

Se crea el archivo del spider dentro de la carpeta más interna, CON EL SIGUENTE COMANDO:
scrapy genspider buscadosJusticia http://https://www.dnrec.jus.gov.ar/masbuscados#/

PRUEBAS UNITARIAS(APUNTES)

Coverage y Pytest(Para la cuestión de las pruebas unitarias)
pytest + ruta al archivo depruebas unitarias
coverage run -m pytest externalSources/projects/ing_quimicos/scrapyIngQuimicos/tests/ingquimicos_test.py
coverage report para ver los porcentajes de covertura
coverage html para que los resultados queden en un nuevo directorio
coverage html para ver detalladamente cada covertura
coverage xml para generar el xml final

Poner en el archivo de requerimientos(similar a como está creado en el ejemplo) todo lo que
 se vaya instalando el archivo de requerimientos lo metí en el proyecto de ejemplo del sisbén

Veriricar que se tenga en cuenta la versión de pyton del cliente o usuario bancolombia ...


AJUSTES(Los pasos están en el documento de word) 
- En default_settingscambiar en RESOURCES EL nombre

2modificiaciones a las referencias de end point ...
HACER TODO CON CAMELCASE
ejm:
"items": [
{
"ID": 1,
"DATA": {
"registroValido": [
{
"mensajeDatosActualizados": "Registro válido",
"grupoSisben": "No pobre no vulnerable",
"fechaConsulta": "02/12/2021",
"ficha": 5631026560300000703,
"nombres": "HECTOR FREDY",
"apellidos": "BAENA CASAS",
"tipoDocumento": "Cédula de ciudadanía",
"numeroDocumento": "15348187",
"municipio": "Sabaneta",
"departamento": "Antioquia",
"cantidadCamposNoEncontrados": 1
}
],
"informacionAdministrativa": [
{
"encuestaVigente": "08/10/2019",
"ultimaActualizacionCiudadano": "10/10/2019",
"ultimaActualizacionRegistrosAdministrativos": ""
}
]
}
}
],


...
Si es un elemento el json es diferente que cuando son varios ...


PASOS PARA SUBIR AL REPOSITORIO:
* Desde cmd como admin(git config --list)-para ver los parámetros configurables
*Configurar lo siguiente: git config --global user.name "gilbertrendon" ó el usuario de bancolombia
git config --global user.email "jilberlv@gmail.com"
git commit --amend --reset-author


git pull origin feature/ConsultaPuntajeSisben

git add --all ó git add .
git fetch origin feature/ConsultaPuntajeSisben
git commit -m "nombreDelCommit"
git push origin feature/ConsultaPuntajeSisben
(conde feature/ConsultaPuntajeSisben es la rama sobre la que se está trabajando)

*git checkout feature/ConsultaPuntajeSisben
Para devolver cambios

* Nota: Se trabaja similarmente a la alcaldía los pull request

Nota: Se metió la carpeta tutorial dentro delproyecto de bancolombia al nivel de SISBEN
CPIQ - INGENIEROS QUIMICOS
TERCERA FUENTE:Está en Inventario Fuentes Externas Publicas VF.xlsx
link: https://www.cpiq.gov.co/validacion_matricula_profesional.php

Cuando se ingresa la identificación del usuario:
Request URL: https://www.cpiq.gov.co/validacion_matricula_profesional.php    (POST)
Debo enviar cedula y el otro codigo desde el cliente de posman
Una cédula de ejemplo es la siguiente: 1030590657

demjson==2.2.4

scrapy==2.5.1

scrapyrt==0.12.0

requests==2.26.0

python-anticaptcha==0.7.1

SE DEBE LLENAR EL INSUMO PARA EL FRONT END(En una parte describe los elementos que tiene la página web por ejemplo textboxs, Listas desplegables, etc)
*Se deben quitar activarambiente.bat, desactivarambiente.bat
*instalar_dev.ps1 arrastrar ...
*ejecutardev se debe cambiar el nombre de la carpeta y scrapy...
*La(s) carpéta(s) logs no se sube(n)
*las variables del jsonUserData deben ir en español(teniendo en cuenta que en la página web puede que vayan en inglés)
*todas las variables locales van a aser en minúsculas separadas por guión cuando son variables compuestas
*...Hay una parte que el True es false ...

DOCKER:
 docker build -t ing_q .
 docker run -p 80:8080 ing_quimicos

AJUSTES SPIDER:
"""
    To consult the data of engineer using POST, the service must be started with:
     scrapyrt -i 0.0.0.0 -p 8080

    Then the data that is sent by POST must have the following structure:
        {
           "jsonUserData": "{\"rowId\":1,\"id_number\":\"1030590657\",\"id_mp\":\"\",\"verificar\":\"\"}",
           "spider_name": "ingenierosQuimicos",
           "start_requests": "True"  
        }

    The json returned by the spider has the following structure:
        {
            "status": "ok",
            "items": [
                {
                    "ID": 1,
                    "DATA": {
                        "nombre": "JHONATAN",
                        "apellidos": "GÓMEZ RAMIREZ",
                        "numeroDocumento": "1030590657",
                        "numeroMatriculaProfesional": "18409",
                        "tipoSancion": "N/A",
                        "fechaInicioSancion": "N/A",
                        "fechaTerminacionSancion": "N/A",
                        "numeroResolucion": "13323",
                        "estadoMatricula": "Vigente",
                        "fechaExpedicion": "12-09-2014"
                    }
                }
            ],
            "items_dropped": [],
            "stats": {
                "downloader/request_bytes": 938,
                "downloader/request_count": 3,
                "downloader/request_method_count/GET": 2,
                "downloader/request_method_count/POST": 1,
                "downloader/response_bytes": 113241,
                "downloader/response_count": 3,
                "downloader/response_status_count/200": 3,
                "elapsed_time_seconds": 3.065753,
                "finish_reason": "finished",
                "finish_time": "2021-12-23 18:08:29",
                "httpcompression/response_bytes": 98,
                "httpcompression/response_count": 1,
                "item_scraped_count": 1,
                "log_count/DEBUG": 4,
                "log_count/INFO": 9,
                "request_depth_max": 1,
                "response_received_count": 3,
                "robotstxt/request_count": 1,
                "robotstxt/response_count": 1,
                "robotstxt/response_status_count/200": 1,
                "scheduler/dequeued": 2,
                "scheduler/dequeued/memory": 2,
                "scheduler/enqueued": 2,
                "scheduler/enqueued/memory": 2,
                "start_time": "2021-12-23 18:08:26"
            },
            "spider_name": "ingenierosQuimicos"
        }

    Example 2: When ERROR OR DATA NOT FOUND
    Then the data that is sent by POST must have the following structure:
        {
           "jsonUserData": "{\"rowId\":1,\"id_number\":\"ASDFASDF\",\"id_mp\":\"\",\"verificar\":\"\"}",
           "spider_name": "ingenierosQuimicos",
           "start_requests": "True"  
        }
    
    The json returned by the spider has the following structure:
     {
            "status": "ok",
            "items": [
                {
                    "ID": 1,
                    "DATA": {
                        "mensaje": "No se encuentra información para el ingeniero químico seleccionado."
                    }
                }
            ],
            "items_dropped": [],
            "stats": {
                "downloader/request_bytes": 936,
                "downloader/request_count": 3,
                "downloader/request_method_count/GET": 2,
                "downloader/request_method_count/POST": 1,
                "downloader/response_bytes": 110639,
                "downloader/response_count": 3,
                "downloader/response_status_count/200": 3,
                "elapsed_time_seconds": 3.411011,
                "finish_reason": "finished",
                "finish_time": "2021-12-23 18:13:39",
                "httpcompression/response_bytes": 98,
                "httpcompression/response_count": 1,
                "item_scraped_count": 1,
                "log_count/DEBUG": 4,
                "log_count/INFO": 9,
                "request_depth_max": 1,
                "response_received_count": 3,
                "robotstxt/request_count": 1,
                "robotstxt/response_count": 1,
                "robotstxt/response_status_count/200": 1,
                "scheduler/dequeued": 2,
                "scheduler/dequeued/memory": 2,
                "scheduler/enqueued": 2,
                "scheduler/enqueued/memory": 2,
                "start_time": "2021-12-23 18:13:35"
            },
            "spider_name": "ingenierosQuimicos"
        }

    """

OBSERVACIONES JUAN: Jose el último star Request , debe ir en False :
Acticvar los artifactory y deshabilitar lo otro
En Coverage en vez de la ruta debe quedar el nombre de la carpeta donde se está parado



***********************************************************************************
Organizador de actividades de narcotráfico agravado por el numero de personas intervinientes y otros.
Salta
Ivan Marcelo

************************************
Se pega el contenido del proyecto pasado
Fila 113 de excel
Para tener el venv activo:
ejecutar en powershell el instalar_dev


link: http://https://www.dnrec.jus.gov.ar/masbuscados#/
Ejemplo de path del elemento nombre:
"nombre": response.css("body > section > div > div > div > div:nth-child(8) > div:nth-child(1) > div > div.panel-footer > a > h4::text").get()

Se nombra la carpeta raiz: BUSCADOS_JUSTICIA
Se siguen los pasos del Dockerfile ... HAY QUE TENER CUIDADO CON LA LINEA DE WORKDIR

El directorio generalLibraries se está dejando igual debido a que estas variables no van ligadas directamente con el spider
Pero en libraries que queda dentro de la carpeta del projecto si se cambian las variables de acuerdo a lo que se envía en el json de postman

Comandos para el encarpetado y el spider:
scrapy startproject scrapyBJusticia
scrapy genspider bJusticia http://https://www.dnrec.jus.gov.ar/masbuscados#/

JSON que se está mandando en el body del postman:
{
    "jsonUserData": "{\"rowId\":1,\"delito\":\"421341234\",\"provincia\":\"1234\",\"nombres\":\"1234\"}",
    "spider_name": "buscadosJusticia",
    "start_requests": "True"
}

*******************************************************************
Ajuste a las fuentes
quitar el parámetro rowId
agregar cambio en nueva rama (feature/migracionSQS)
cambios en documentacion 
en pruebas 
jmeter
en el rest
json de entrada y salida
también en os insumos para el front end
EN TODO LO QUE TENGA EL ROWID


Orden de los cambios hechos:
en el spider se borra de los comentarios lo relacionado al rowId
también se debe tener en cuenta que en las salidas e campo ID desaparece
seguidamente en el final_output se quita lo siguiente: 
self.general_cons.INFOID: self.jsonUserData["rowId"],
final_output["ID"] = self.jsonUserData["rowId"]

se quita lo siguiente en las constantes de los tets: "rowId":"{rowId}",
por lo que en el archivo de los test se quita: rowId = 1,


en el jmeter dentro de la carpeta test en Prueba.jmx se quitó también la parte del rowId
------------------------------------------------------------------------------------------------

+ Los jsonUserData en el archivo REST-Project-1-readyapi-project.xml no coinciden, revisar punto 8.1 en checklist
No se detectan errores al respecto solo se cambiaron valores por filtros que si traigan respuestas


+ Los jsonUserData en el archivo Prueba.jmx no coincide con el de REST-Project-1-readyapi-project.xml , revisar punto 12 en checklist



+ Error en json salida de spider, debe tener formato correcto hayan o no hayan resultados, revisar punto 4 en checklist.
 JSON de entrada usado: { "jsonUserData": "{"tipo":"Filtro_Provincias","valor":"SADFADFASDF"}", "spider_name": "bJusticia", "start_requests": "True"}

-----------------------------------------------------------------

SI LA FUENTE NO TIENE FEATURES/MIGRACIONSQS HAY QUE HACER TODOS ESOS PASOS(LO DEL ROWID Y TODO)

En ingenieros químicos está la referencia para los nuevos cambios EN LA RAMA MIGRACIÓN LISTENER ...
Crear la rama features/migracionSQS
En el archivo sqs.sh(revisarlo) Se ejecuta un comando desde el proyecto mío que estoy arreglando que apunte a este archivo(está dentro de ING_QUIMICOS)

En la araña
imprimir json.dumps(respuesta) para mostrar info que se debe mostrar antes del yield(Nos podemos guiar de ing quimicos o de banrep)
En el archivo de pruebas:
verificar que se tiene instalado wsl(corriendo wsl desde powershell) y se abre power shel integrated console
tener instalado el venv actualizado
NOTA: se puede instalar  wsl --install -d Ubuntu(pero en la fuente de biología no me funcionano)

LUEGO DE EJECUTAR EL sqs.sh
ejecutar_dev_sqs.psl en una consola de powershell normal
se ejecuta el enviar_mensaje

En el Dockerfile se coloca lo siguiente:
ENV urlQueue="https://sqs.us-east-1.amazonaws.com/698662101601/nu0030001-fuentes-externas-dev-universidades.fifo"
ENV urlQueueAns="https://sqs.us-east-1.amazonaws.com/698662101601/queueEntregaaCSV.fifo"
ENV AWS_ACCESS_KEY_ID="AKIA2FK4BUJQ35FHF25R"
ENV AWS_SECRET_ACCESS_KEY="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"

PARA LAS PRUEBAS DE COVERTURA:
coverge erase
coverage run -m pytest externalSources\projects\ofac\scrapyOFAC\tests (CON EL NOMBRE DE MI PROYECTO)
salen las pruebas de test, las de listener y las de 

el listener.PY la linea 26 no se sube(MIRAR VIDEO DE ANDRES RINCON)

Para problemas de ssl(En el archivo sqs_client.py) linea 5 agregar verify=false en los parámetros
(TICKET: 91906383) https://nextgenghd.ultimatix.net/NextGenGHD/index.html?cd=1644936965122#/ViewTickets
Jhon Mercado de la Rosa









