let map;
let markers = [];
let initialLat = 42.74;
let initialLng = -73.26;
let initialZoom = 6;
const resetControl = L.control({position: 'topleft'});
const logo = L.control({position: 'topright'});

setTimeout(function () {
    location.reload();
  }, 5 * 60 * 1000)

map = L.map('map').setView([initialLat, initialLng], initialZoom); // Centered at NE

L.tileLayer('https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}', {
    maxZoom: 20,
    subdomains:['mt0','mt1','mt2','mt3']
}).addTo(map);

window.addEventListener('load', function() {
    map.invalidateSize();
});

async function handleFile() {
    const response = await fetch('exported.csv');
    const csvData = await response.text();
    const data = parseCSVData(csvData);

    plotAddresses(data);
}

resetControl.onAdd = function (map) {
    const resetButton = L.DomUtil.create('button', 'reset-button');
    resetButton.innerHTML = 'Reset Map';
    resetButton.onclick = function () {
        map.setView([initialLat, initialLng], initialZoom);
        location.reload();
    };
    return resetButton;
};

resetControl.addTo(map);

logo.onAdd = function(map){
    var div = L.DomUtil.create('div', 'mylogo');
    div.innerHTML= "<img src='sai_logo.png'/>";
    return div;
}

logo.addTo(map);




// Call the function immediately when the script loads
handleFile();

fetch('us-states.json')
    .then(response => response.json())
    .then(data => {
        L.geoJSON(data, {
            style: function(feature) {
                return {color: "#FFFFFF", weight: .5};
            }
        }).addTo(map);
    });


    function parseCSVData(data) {
        const rows = data.split('\n');
        return rows.map(row => {
            const columns = row.split(',');
            return {
                jobName: columns[0], 
                address: columns.slice(1, 4).join(', '),
                state: columns[3],
                jobType: columns[4],
                jobDesc: columns[5], 
                jobOwner: columns[6],
                jobSage: columns[7]
            };
        });
    }
    

async function geocodeAddress(address) {
    const apiKey = '01a6682e4a8f4d408a6312f4644b1639';
    const response = await fetch(`https://api.opencagedata.com/geocode/v1/json?q=${encodeURIComponent(address)}&key=${apiKey}`);
    const data = await response.json();

    // Check if any results were returned
    if (data.results && data.results.length > 0) {
        return {
            lat: data.results[0].geometry.lat,
            lng: data.results[0].geometry.lng
        };
    } else {
        console.error('No geocoding results for address: ' + address);
        return {
            lat: NaN,
            lng: NaN
        };
    }
}


const icons = {
    'EVCI': L.icon({iconUrl: 'green-icon.png',shadowUrl: 'marker-shadow.png', iconSize: [25, 41], iconAnchor: [12, 41],shadowAnchor: [12, 41],shadowSize: [41, 41]}),
    'Telecom-DAS': L.icon({iconUrl: 'blue-icon.png',shadowUrl: 'marker-shadow.png', iconSize: [25, 41], iconAnchor: [12, 41],shadowAnchor: [12, 41],shadowSize: [41, 41]}),
    'Telecom-Tower': L.icon({iconUrl: 'gold-icon.png',shadowUrl: 'marker-shadow.png', iconSize: [25, 41], iconAnchor: [12, 41],shadowAnchor: [12, 41],shadowSize: [41, 41]}),
    'HQ': L.icon({iconUrl: 'orange-icon.png',shadowUrl: 'marker-shadow.png', iconSize: [25, 41], iconAnchor: [12, 41],shadowAnchor: [12, 41],shadowSize: [41, 41]})
};

function plotAddresses(addresses) {
    // Clear old markers
    markers.forEach(marker => map.removeLayer(marker));
    markers = [];

    const list = document.getElementById('list');
    while (list.rows.length > 1) {
        list.deleteRow(1); // Clear old list but keep header
    }

    addresses.forEach((address, index) => {
        geocodeAddress(address.address)
            .then(coords => {
                if (isNaN(coords.lat) || isNaN(coords.lng)) {
                    console.error('Invalid coordinates', coords);
                    return;
                }

                const icon = icons[address.jobType] || L.Icon.Default; // Use default icon if job type is not recognized
                const marker = L.marker([coords.lat, coords.lng], {icon: icon}).addTo(map);
                
                // Add Tooltip
                marker.bindTooltip(`${address.jobName}
                <br>${address.jobOwner.toUpperCase()}
                <br>${address.jobDesc}
                <br>${address.jobSage}`
                );

                // Add click event to marker
                marker.on('click', function(e) {
                    map.setView(e.target.getLatLng(), 15);
                });

                markers.push(marker);

                const row = list.insertRow();
                let cell = row.insertCell();
                cell.textContent = address.jobName;
                cell = row.insertCell();
                cell.textContent = address.jobType;
                cell = row.insertCell();
                cell.textContent = address.state.substring(0,2);
                
                // Zoom to pin after clicking on project in table
                row.addEventListener('click', function() {
                    map.setView([coords.lat, coords.lng], 15);
                });

                // Add the marker animation when hovering over a table row
                row.addEventListener('mouseover', function() {
                    marker.setOpacity(0.5); // Set the opacity to a lower value
                });

                row.addEventListener('mouseout', function() {
                    marker.setOpacity(1); // Reset the opacity back to 1
                });

            })
            .catch(error => console.error('Geocoding error', error));   
    });
}
