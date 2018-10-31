<html> 
<head> 
<meta name="viewport" content="initial-scale=1.0, user-scalable=no" /> 
<meta http-equiv="content-type" content="text/html; charset=UTF-8"/> 
<title>Google Maps JavaScript API v3 Example: Markers, Info Window and StreetView</title> 
<link href="http://code.google.com/apis/maps/documentation/javascript/examples/default.css" rel="stylesheet" type="text/css" /> 
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script> 
<script type="text/javascript"> 
  function initialize() {

    // Create the map 
    // No need to specify zoom and center as we fit the map further down.
    var map = new google.maps.Map(document.getElementById("map_canvas"), {
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      streetViewControl: false
    });
 
    // Define the list of markers.
    // This could be generated server-side with a script creating the array.
    var markers = [
      { lat: -33.85, lng: 151.05, name: "marker 1" },
      { lat: -33.90, lng: 151.10, name: "marker 2" },
      { lat: -33.95, lng: 151.15, name: "marker 3" },
      { lat: -33.85, lng: 151.15, name: "marker 4" }
    ];

    // Create the markers ad infowindows.
    for (index in markers) addMarker(markers[index]);
    function addMarker(data) {
      // Create the marker
      var marker = new google.maps.Marker({
        position: new google.maps.LatLng(data.lat, data.lng),
        map: map,
        title: data.name
      });
    
      // Create the infowindow with two DIV placeholders
      // One for a text string, the other for the StreetView panorama.
      var content = document.createElement("DIV");
      var title = document.createElement("DIV");
      title.innerHTML = data.name;
      content.appendChild(title);
      var streetview = document.createElement("DIV");
      streetview.style.width = "200px";
      streetview.style.height = "200px";
      content.appendChild(streetview);
      var infowindow = new google.maps.InfoWindow({
        content: content
      });

      // Open the infowindow on marker click
      google.maps.event.addListener(marker, "click", function() {
        infowindow.open(map, marker);
      });
    
      // Handle the DOM ready event to create the StreetView panorama
      // as it can only be created once the DIV inside the infowindow is loaded in the DOM.
      google.maps.event.addListenerOnce(infowindow, "domready", function() {
        var panorama = new google.maps.StreetViewPanorama(streetview, {
            navigationControl: false,
            enableCloseButton: false,
            addressControl: false,
            linksControl: false,
            visible: true,
            position: marker.getPosition()
        });
      });
    }

    // Zoom and center the map to fit the markers
    // This logic could be conbined with the marker creation.
    // Just keeping it separate for code clarity.
    var bounds = new google.maps.LatLngBounds();
    for (index in markers) {
      var data = markers[index];
      bounds.extend(new google.maps.LatLng(data.lat, data.lng));
    }
    map.fitBounds(bounds);
  }
</script> 
</head> 
<body onload="initialize()"> 
  <div id="map_canvas"></div> 
</body> 
</html>

Posted 8th November 2010 by Marc (Google Employee)
Labels: Api maps StreetView v3
View comments
Marc Ridey - Blog

    Classic
    Flipcard
    Magazine
    Mosaic
    Sidebar
    Snapshot
    Timeslide

Jun
24
How to setup your Blogger blog with GoDaddy
We've recently launched a new feature in custom domains that lets you download a DNS file that contains all the DNS settings you need to configure your blog on a custom domain.

GoDaddy DNS service supports this feature so Let's show you how it's done:

For this demo, I assume you have an existing blog and you have already purchased a domain on GoDaddy.

Step 1: Go to the Settings Tab of your blog in the Blogger UI and click on the "Add a custom domain" link.

Step 2: Enter the URL you would like to use for your blog and press Save. I'm using "www.thisdemoblog.com" but the URL doesn't need to start with www such as "blog.mridey.com" where I published this article.

Step 3: You will get an error. It's expected as you have not configured GoDaddy with the DNS settings required.
Mar
23
How to setup your Blogger blog with a custom domain from 1and1.com - Simplified
Good news, the domain ownership verification system has been modified to use shorter string, allowing it to work with the limited 1and1.com DNS system.

Update: If you have a domain with GoDaddy, follow these instructions: http://blog.mridey.com/2013/06/how-to-setup-your-blogger-blog-with.html

Here's how to setup your 1and1.com domain for Blogger.

Step 1: Get the Blogger settings

- Go to the basic settings of your blog in the Blogger UI.
Feb
6
Building a blog with Google+
Building a successful blog requires a simple element: Good content.

Write good content and readers will come.

I can’t help you with good content, but I can provide some ideas on how to get readers coming sooner rather than later.

Let’s first ignore technology and look at how a blog grows from zero readers to millions of readers. To build readership, you need to complete three steps:

First, your content must be discoverable  So people that have never seen your blog can be directed to it.
Oct
24
How to setup your Blogger blog with a custom domain from 1and1.com
Update: 

The Domain ownership system has been updated and using a 1and1.com domain is now much simpler. use the new instructions here: http://blog.mridey.com/2013/03/how-to-setup-your-blogger-blog-with.html

==============================================

Recently, Blogger added extra security when configuring a blog using a custom domain.

You know need to setup two CNAME values in the DNS settings of your domain for Blogger to recognize your custom domain settings.
May
3
Custom maps styles using the "Styled Maps Wizard"
I've just been asked for help on how to create a map with the Terrain background and no roads, no labels.

It is very easy to do using the "Styled Maps Wizard" available here:

http://gmaps-samples-v3.googlecode.com/svn/trunk/styledmaps/wizard/index.html

- Click on Map in the top right

- Select terrain ON

At this point you should have a map with the terrain and labels.
Oct
4
Dynamic markers in Maps API Javascript v3
Another option for labels is to use dynamic markers.

These are provided by the Google Chart tools API.

You can set the shape, color and text of each marker.

The documentation for the markers can be found at

http://code.google.com/apis/chart/infographics/docs/dynamic_icons.html.
May
22
Label overlay example for Google Maps API v3 - Revisited
A while back I published a post showing how to add a label to a marker. I got a lot of comments on that post, in particular regarding adding support for visibility, zIndex and click event.

So here's a revised version.
Nov
8
Using StreetViewService in Maps API Javascript v3
Based on my recent post, I've added code to change the content of the infowindow if the panorama we try to display doesn't exist. This needs to be done using StreetViewService as currently the StreetViewPanorama doesn't have an event or property to notify us of a failure to load a panorama.

The code that changed:

// Create a StreetViewService to be able to check // if a given LatLng has a corresponding panorama.
Nov
8
Maps API Javascript v3 - Multiple Markers with multiple infowindows and StreetView
Similar to the previous post, I have a map with multiple markers but multiple InfoWindows, one per marker. When a marker is clicked, its infowindow is displayed with the marker title and the StreetView panorama at this location.
Nov
8
Maps API Javascript V3 - Multiple Markers, InfoWindow and StreetView
Another interesting example. For this blog, I have a map with multiple markers and a single InfoWindow shared between the markers. When a marker is clicked, the infowindow is displayed with the marker title and the StreetView panorama at this location.
Nov
5
How to display a map inside StreetView
It's fairly easy to display a small map in the corner of a StreetView panorama.

You just need to add a small map on top of the StreetView panorama and bind it.
Nov
5
How to embed StreetView in an infowindow
I've received a number of queries on how to get StreetView inside an infowindow showing the panorama of the marker bound to the infowindow.

Here's a quick example.

Click on the marker to display the infowindow.

Drag the marker to get a different panorama.
May
26
How to create and display a custom Street View panorama using Maps Javascript API v3
To display a custom panorama, first you need a tileset.

There are no restrictions to the tileset size or aspect ratio, the tile size or aspect ratio and the number of tiles used.

Just know that StreetView uses an equirectangular projection (http://en.wikipedia.org/wiki/Equirectangular_projection)

so the panorama will be stretched to wrap exactly around a sphere horizontally and exactly half a sphere vertically. For this reason, a panorama with an aspect ratio 2:1 is best.
May
19
Custom panoramas in Maps Javascript API v3 - Street View
How to display a custom panorama

Register a pano provider in the panorama that returns a StreetViewPanoramaData. The critical element is the 'tiles' property that defines the set of tiles required for the panorama.
May
19
Controls in Maps Javascript API v3 - Street View
Controls in Street View are very similar to the Map controls.

How to show/hide the address control

panorama.set('addressControl', true/false);

or

panorama.setOptions({

addressControl: true/false

});

how to position the address control in the panorama

panorama.setOptions({

'addressControlOptions': {

'position': google.maps.ControlPosition.TOP_RIGHT,

...
May
19
Events, markers, infowindows and overlays in Maps Javascript API v3 - Street View
How to monitor changes to pano Id

google.maps.event.addListener(panorama, 'pano_changed', function() {});

How to monitor changes to position

google.maps.event.addListener(panorama, 'position_changed', function() {});

How to monitor changes to the point of view

google.maps.event.addListener(panorama, 'pov_changed', function() {});

How to add a marker in the panorama

Markers by default are shared between the map and the panorama.
May
19
Enabling and initializing Street View in Maps Javascript API v3
How to enable Street View

map.set('streetViewControl', true);or

map.setOptions({

streetViewControl: true

});

How to access the panorama in the map

var panorama = map.getStreetView();

How to know if the panorama is displayed

var panoramaDisplayed = panorama.getVisible();

How to set a manual Pano Id

panorama.setPano('-gfXi6db7jFB-cwAkTbBgA');or

panorama.setOptions({

pano: '-gfXi6db7jFB-cwAkTbBgA'

});

How to set a manual position

panorama.setPosition(new google.maps.LatLng(48.85969,
Mar
25
Using MarkerImage in Maps Javascript API v3
When creating custom markers, you need to supply two images, the icon and the shadow. While you can supply a simple URL for each property, using MarkerImage allows you more flexibility and improves performance.

1. Creating a simple image:

The simplest marker is one made of individual icon and shadow images, with the anchor point (The point used to position the marker) located in the middle of the bottom edge of the image, like the standard marker using by the API.
Mar
24
Maps Javascript API v3 - More about the MVCObject class
If you’re doing development using the new Google Maps JavaScript API v3, you will have noticed that all the core classes are derived from the MVCObject class.

Knowing when and how to use the features built into the MVCObject class will make your Maps API v3 development easier.

1. Accessors

To store and retrieve values from an MVCObject, do not access the properties directly, instead use the provided accessor methods.

get(key): Retrieves a value from the MVCObject.
Sep
29
Listening to map events in Google Maps API v3 OverlayView
In my previous post, I showed how to create a simple Label overlay. In that example, the draw method was only called when the position of the overlay relative to the map needed to be recalculated or when the text for the label had changed.

But what if the look/content of the overlay you want to create depends on the map center or the map bounds. Currently, OverlayView.draw is not called if the map is dragged for example.
Sep
28
Label overlay example for Google Maps API v3
Here's a simple example of creating a custom overlay class for Google Maps API v3. This Label overlay can either be used on its own, or bound to a marker.

First, create the Label class and place it in a label.js file.
Sep
10
Hosting Google Maps in a Microsoft WPF application using XAML
Ever wondered how to implement Google Maps in a WPF application using XAML?

Find out how: http://code.google.com/apis/maps/articles/flashmapinwpf.html
May
4
Filtered ObservableCollection
On the project I'm working on at the moment, I have a class that stores items in an ObservableCollection. I needed to be able to expose in the same class different subsets of this collection, keeping them all in sync while allowing to add/remove/update elements in all the collections.
May
4
Attached DependencyProperty
In my previous blog on DependencyProperty, I talked about how to create properties in objects using DependencyProperty and DependencyObject, to have support for Databinding, defaults, expressions, events and validations.

But on some occasions, you want to assign a parent object needs to assign a property to the children objects, regardless of the type of object.

Traditionally, this has been done using base class and inheritance.
May
4
DependencyProperty and DependencyObject
Up until now, you would create properties in a class using this syntax:

public

class

MyObject

{

private

string MyPropertyValue;

public

string MyProperty

{

set

{

MyPropertyValue = value;

}

get

{

return MyPropertyValue;

}

}

}

