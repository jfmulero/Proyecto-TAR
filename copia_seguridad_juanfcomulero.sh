#! /bin/bash
#Juniyo23
#jfmulero.fuentes@gmail.com

fecha=`date +"Mes-"%m"_Dia-"%d"_Hora-"%H"-"%M`
usuario=`hostname | cut -d "-" -f1`

function copiaDisco_outGui(){

	salida=1

	while [[ $salida -eq 1 ]]; do

		read -p "Introduce la ruta sobre la que realizar la copia de seguridad:" copia
		if [[ -d "$copia" ]]; then
			tar -cpvzf "$fecha""_completa".tar.gz $copia
			let salida=0

			
		else
			clear
			echo "La ruta para hacer la copia de seguridad no existe, intentalo de nuevo"
		fi
	done

	while [[ $salida -eq 0 ]]; do

		echo "Discos disponibles: "

		for (( i = 0 ; i <= 20; i++ )); do
			mount | grep sd[b-z] | awk -F 'type' '{print $1}' | grep -n sd[b-z] | grep "$i:"
		done
		
		read -p "Introduce el número de disco donde guardar la copia de seguridad: " num1

		disco_int=`mount | grep sd[b-z] | awk -F 'type' '{print $1}' | grep -n sd[b-z] | grep "$num1:" | awk -F 'on' '{print $2}'`


		if [[ "$disco_int" ]]; then
			
			cp ./$fecha.tar $disco_int

			echo ""
			echo "Copia movida correctamente a $disco_int"
			echo ""

			let salida=1

		else
			echo "Dispositivo extraible no encontrado, intentalo de nuevo"
		fi
	done

}


function menu_withgui(){

	menu=$(zenity --width=660 --height=620 --list --title="Menú" --text="Elige una opción" --column=Opciones "Copia de seguridad" "Pasar copia de seguridad a unidad extraible" "Pasar copia de seguridad mediante SSH" "Salir")
	case $menu in
		"Copia de seguridad" ) sub_menuzen=$(zenity --width=660 --height=620 --list --title="Menú" --text="Elige una opción" --column=Opciones "Copia completa" "Copia incremental")
		case $sub_menuzen in

			"Copia completa" ) ruta_menuzen=$(zenity --file-selection --directory)

				#Comprobamos si existe la carpeta Snap
				if [[ -d "/home/$usuario/Snap" ]]; then

					#Las siguientes variables sirven para cortar la ultima ruta seleccionada por el usuario
					modificacion=`echo $ruta_menuzen | sed 's/\//-/g'`

					#crea una copia completa de la ruta seleccionada por el usuario
					tar -czvf "$fecha""_completa""$modificacion".tar.gz "$ruta_menuzen"

					#si no existe la carpeta /Snap se crea
					else

						mkdir /home/$usuario/Snap
				
					#Las siguientes variables sirven para cortar la ultima ruta seleccionada por el usuario
					modificacion=`echo $ruta_menuzen | sed 's/\//-/g'`

					#crea una copia completa de la ruta seleccionada por el usuario
					tar -czvf "$fecha""_completa""$modificacion".tar.gz "$ruta_menuzen"

					fi ;;

			"Copia incremental" ) ruta_menuzen=$(zenity --file-selection --directory)
				
				#Las siguientes variables sirven para cortar la ultima ruta seleccionada por el usuario
				modificacion=`echo $ruta_menuzen | sed 's/\//-/g'`
				linea=`echo $ruta_menuzen | grep -o "/" | wc -l`
				ultimo=`expr $linea + 1`
				cortar=`echo $ruta_menuzen | cut -d "/" -f$ultimo`

				#Si la carpeta Snap no esta creada, se crea
				if [[ -d "/home/$usuario/Snap" ]]; then

					#comprobamos si la ruta introducida por el usuario ya tiene o no copia incremental
						new_cortar=`echo $cortar | cut -d"/" -f2`
						comp_snap=`ls /home/$usuario/Snap/ | grep -o $new_cortar`

						if [[ $comp_snap != "" ]]; then
							comp_snap_bool=1
						else
							comp_snap_bool=0
						fi
	
						if [[ $comp_snap_bool == 0 ]]; then

							#crea una copia incremental que llamaremos "cmpleta" de la ruta seleccionada por el usuario, ya que no existe ninguna incremental de la ruta
							tar -czvf "$fecha""_incremental""$modificacion".tar.gz "$ruta_menuzen"

							echo "Se ha realizado una copia completa, ya que no existia ninguna incremental previa"

							else

								#crea una copia incremental

								tar -czvf "$fecha""_incremental""$modificacion".tar.gz --listed-incremental=/home/$usuario/Snap/$new_cortar.snap "$ruta_menuzen"

						fi

					#si no existe la carpeta /Snap se crea
					else

						mkdir /home/$usuario/Snap

						#creamos un archivo que nos va a permitir ayudarnos a la hora de crear copias diferenciales
						echo "Completa `date`"" $ruta_menuzen" >> "/home/$usuario/Snap/Fullbackup"

						#crea una copia incremental que llamaremos "cmpleta" de la ruta seleccionada por el usuario, ya que no existe ninguna incremental de la ruta
							tar --create \
								--file="$fecha""_completa""$modificacion".tar \
								--listed-incremental=/home/$usuario/Snap/"$new_cortar".snap \
								$cortar

							echo "Se ha realizado una copia completa, ya que no existia ninguna incremental previa"

				fi ;;

			"Copia diferencial") ruta_menuzen=$(zenity --file-selection --directory)
		
				fecha_menuzen=$(zenity --text "Elige una fecha desde la que realizar la copia " --calendar)
				conversion_fecha1=`echo $fecha_menuzen | cut -d"/" -f1`
				conversion_fecha2=`echo $fecha_menuzen | cut -d"/" -f2`

				if [[ $conversion_fecha2 == "01" ]]; then
					mes="jan"
				elif [[ $conversion_fecha2 == "02" ]]; then
						mes="feb"
				elif [[ $conversion_fecha2 == "03" ]]; then
						mes="mar"
				elif [[ $conversion_fecha2 == "04" ]]; then
						mes="apr"
				elif [[ $conversion_fecha2 == "05" ]]; then
						mes="may"
				elif [[ $conversion_fecha2 == "06" ]]; then
						mes="jun"
				elif [[ $conversion_fecha2 == "07" ]]; then
						mes="jul"
				elif [[ $conversion_fecha2 == "08" ]]; then
						mes="aug"
				elif [[ $conversion_fecha2 == "09" ]]; then
						mes="sep"
				elif [[ $conversion_fecha2 == "10" ]]; then
						mes="oct"
				elif [[ $conversion_fecha2 == "11" ]]; then
						mes="nov"
				elif [[ $conversion_fecha2 == "12" ]]; then
						mes="dic"
				fi

				conversion_fecha3=`echo $fecha_menuzen | cut -d"/" -f3`

				#Las siguientes variables sirven para cortar la ultima ruta seleccionada por el usuario
				modificacion=`echo $ruta_menuzen | sed 's/\//-/g'`
				linea=`echo $ruta_menuzen | grep -o "/" | wc -l`
				ultimo=`expr $linea + 1`
				cortar=`echo $ruta_menuzen | cut -d "/" -f$ultimo`

				tar -cpvzf "$fecha""_diferencial""$modificacion".tar "$cortar" -N $conversion_fecha1"$mes""20"$conversion_fecha3
				;;

		esac
			;;

		 	"Pasar copia de seguridad a unidad extraible" ) discos_zen=$(zenity --list --column "Selecione un disco" `for i in $(ls /media/$usuario/); do
		 		echo "$i"
		 	done`)
		 	mv_zen=$(zenity --file-selection)
		 	mv $mv_zen "/media/$usuario/"$discos_zen
		 	echo $mv_zen $discos_zen
		 	;;


	esac

}

function menu_outgui(){

	salida_menu=1

	while [[ $salida_menu != 10 ]]; do

		echo "~~~~~~~~~~~~~~~~~~~"
		echo "	Menú"
		echo "~~~~~~~~~~~~~~~~~~~"
		echo "Opción 1: Crear copia de seguridad"
		echo ""
		read -p "Introduce una opción: " opcion_menu

		case $opcion_menu in
			1) realizar_copia;;
			*) echo "Opción no válida";;
		esac

		read -p "Pulse intro para continuar: " intro
		clear
	done

}

clear
read -p "Cuenta tu sistema con interfaz gráfica? Si/No: " resp_gui
if [[ $resp_gui == "No" ]]; then
	menu_outgui
fi
if [[ $resp_gui == "Si" || $resp_gui == si || $resp_gui == "SI" ]]; then
	menu_withgui
fi
