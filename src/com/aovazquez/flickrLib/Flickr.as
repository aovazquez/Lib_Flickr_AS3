package com.aovazquez.flickrLib
{
	/**
	 * @description Esta clase fue dasarrollada con el fin de consumir 
	 * 				los servicios de la API de Flickr con AS3.
	 * 
	 * @author Angel Vazquez aovazquez4037@gmail.com
	 */
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import mx.collections.ArrayCollection;

	public class Flickr
	{
		//create URL
		/**
		 * @description URL de como consumir los serviciós de la API de Flickr
		 * 				y de como formar la urls de las imagenes.
		 * 
		 * https://www.flickr.com/services/api/
		 * https://www.flickr.com/services/api/misc.urls.html
		 * https://www.flickr.com/services/api/misc.buddyicons.html 
		 * */
		
		public static var BASE_URL:String  			= "http://api.flickr.com/services/rest/";/** @description URL de Flickr para conectarte a la API*/
		
		// Mas información https://www.flickr.com/services/api/flickr.people.findByUsername.html
		public static var FIND_BY_USERNAME:String  	= "flickr.people.findByUsername";/** @params username en Flickr, @return información del usuario */
		
		// Mas información https://www.flickr.com/services/api/explore/flickr.people.findByEmail 
		public static var FIND_BY_EMAIL:String  	= "flickr.people.findByEmail";/** @params find_email en Flickr, @return información del usuario */
		
		// Mas información https://www.flickr.com/services/api/flickr.photos.search.html
		public static var GET_USER_PHOTOS:String  	= "flickr.urls.getUserPhotos"; /** @params user_id Obligatorio, @return URL del album principal */
		
		// Mas información https://www.flickr.com/services/api/flickr.photos.search.html
		public static var GET_INFO:String  			= "flickr.people.getInfo"; /** @params user_id Obligatorio, @return información completa del usuario */
		
		// Mas información https://www.flickr.com/services/api/flickr.photos.search.html
		public static var SEARCH_PHOTOS_USER:String	= "flickr.photos.search"; /** @params user_id Obligatorio, @return fotos que tiene el usuario o por tag*/
		
		// Mas información https://www.flickr.com/services/api/flickr.photos.getInfo.html
		public static var PHOTOS_GETINFO:String	= "flickr.photos.getInfo"; /** @params photo_id Obligatorio, @return información de la foto*/
		
		// Mas información  https://www.flickr.com/services/api/explore/flickr.photos.getExif
		public static var PHOTOS_GETCAMERA:String	= "flickr.photos.getExif"; /** @param photo_id obligatorio, @return camara con la que fue tomada la imagen*/
		
		
		public var base:String; 
		public var key:String;
		
		/**
		 * @description constructor de la clase
		 * @param key llave o clave que debes de obtener de la siguiente URL para poder hacer uso de la API 
		 * 		  https://www.flickr.com/services/api/misc.api_keys.html
		 * 
		 * @param base URL de base de la API de Flickr
		 * 
		 * **/
		public function Flickr(key:String, base:String='http://api.flickr.com/services/rest/')
		{
			this.key  = key;
			this.base = base;
		}
		
		
		/**
		 * @description Metodo en con el cual se hacen las peticiones hacia la API de Flickr y trae el evento de respuesta
		 
		 * @param method nombre o URI del cual se quiere consumir el servicio(ver API de Flickr)
		 * 
		 * @param params parametros requeridos en formato Object que necesita el metodo a consumir
		 * 
		 * @param completeEventHandler evento que retorna la respuesta del servicio cuando es exitoso
		 * 
		 * @param format formato en el que se quiere que se retorne la respuesta(REST,XML-RPC, SOAP, JSON, PHP)
		 * ver https://www.flickr.com/services/api/
		 * 
		 * @param errorEventHandler evento que retorna si existion un error al consumir el servicio.
		 * 
		 * **/
		public function call(method:String, params:Object, completeEventHandler:Function, format:String = "json",errorEventHandler:Function=null):void
		{
			var loader:URLLoader 	= new URLLoader();
			var request:URLRequest 	= new URLRequest(base);
			var data:URLVariables 	= new URLVariables();
			
			data['method'] 	= method;
			data['api_key'] = key;
			data['format'] 	= format;
			data['nojsoncallback'] = 1;
			
			for (var prop:String in params) {
				data[prop] = params[prop];
			}
			
			request.data = data;
			
			loader.addEventListener(Event.COMPLETE, completeEventHandler);
			if (errorEventHandler != null) {
				loader.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			}
			try { 
				loader.load(request);
			}
			catch (error:Error) {
				if (errorEventHandler != null) {
					errorEventHandler(new ErrorEvent(ErrorEvent.ERROR, false, false, error.message));
				}
			}
		}
		
		/**
		 * @description Metodo para crear la URL del icono de perfil del usuario
		 * @see https://www.flickr.com/services/api/misc.buddyicons.html 
		 * 
		 * @param value objeto que contiene las variables necesarias para crear la URL del icono de perfil
		 * 
		 * @return URL del icono de perfil del usuario
		 * **/
		// size can be _m, _s, _t, or _b
		public function getURLIcon( value:Object ):String
		{
			trace("https://farm"+value.person.iconfarm+".staticflickr.com/"+value.person.iconserver+"/buddyicons/"+value.person.id+"_r.jpg");
			return "https://farm"+value.person.iconfarm+".staticflickr.com/"+value.person.iconserver+"/buddyicons/"+value.person.id+".jpg";
		}
		
		/**
		 * @description Metodo para crear un array de imagenes y de formar las URL's de la respuesta de la busqueda deseada.
		 * @see https://www.flickr.com/services/api/misc.urls.html 
		 * 
		 * @param value array de imagenes de la respuesta de la busqueda deseada.
		 * 
		 * @return ArrayCollection de la respuesta de la busqueda deseada con la URL de las imagenes a mostrar
		 * **/
		public function getArrayPhotosImages( value:Array ):ArrayCollection
		{
			var photos:ArrayCollection = new ArrayCollection();
			for( var i:uint = 0; i<value.length;i++ )
			{
				var o:Object = new Object();
				o 	= value[i];
				//http://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
				o.url = "http://farm"+value[i].farm+".staticflickr.com/"+value[i].server+"/"+value[i].id+"_"+value[i].secret+"_t.jpg"
				/*o.url 	= "https://www.flickr.com/photos/"+value[i].owner+"/"+value[i].id+"/";*/
				photos.addItem(o);
			}
			//https://www.flickr.com/photos/7199157@N03/8576080330/
			/*trace("https://farm"+value.person.iconfarm+".staticflickr.com/"+value.person.iconserver+"/buddyicons/"+value.person.id+"_r.jpg");*/
			return photos;
		}
		
		/**
		 * @description Metodo para crear la URL de una imagen en especifico
		 * @see https://www.flickr.com/services/api/misc.urls.html 
		 * 
		 * @param value objeto con los parametros necesarios para formar la URL
		 * 
		 * @return String de la URL de la imagen a mostrar
		 * **/
		public static function getUrlPhoto( value:Object ):String
		{
			var url:String = "";
			//http://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
			url = "http://farm"+value.farm+".staticflickr.com/"+value.server+"/"+value.id+"_"+value.secret+"_z.jpg"
			return url;
		}
	}
}