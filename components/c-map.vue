<template>
  <div ref="map" class="map" />
</template>

<script>
import skoleDistrikt06 from './Skoledistrikter/Skoledistrikt_0-6.json'
import skoleDistrikt79 from './Skoledistrikter/Skoledistrikt_7-9.json'
import skoleDistrikt10 from './Skoledistrikter/Skoledistrikt_10.json'
export default {
  props: {
    controls: {
      type: Boolean,
      default: false,
    },
    adresse: {
      type: Object,
      default: () => {
        return {
          data: {},
        }
      },
    },
    skoler: {
      type: Object,
      default: () => {
        return {
          type: 'FeatureCollection',
          features: [],
        }
      },
    },
    skole: {
      type: Object,
      default: () => {},
    },
    route: {
      type: Array,
      default: () => [],
    },
  },
  watch: {
    adresse() {
      this.setAdresse()
    },
    skoler(val) {
      this.setSkoler()
    },
    skole(val) {
      this.setSkole()
    },
    route() {
      this.setRoute()
    },
  },
  mounted() {
    this.$L.MakiMarkers.accessToken =
      'pk.eyJ1IjoicnVuZXR2aWx1bSIsImEiOiJkeUg2WVkwIn0.yoMmv3etOc40RXkPsebXSg'
    const skoledistrikter06 = this.$L.geoJson(skoleDistrikt06)
    const skoledistrikter79 = this.$L.geoJson(skoleDistrikt79)
    const skoledistrikter10 = this.$L.geoJson(skoleDistrikt10)
    // Set Kortforsyningen token, replace with your own token
    const kftoken = 'b71507e0430f6b3c320d3aef5c466353'

    // Set the attribution (the copyright statement shown in the lower right corner)
    // We do this as we want the same attributions for all layers
    const myAttributionText =
      '&copy; <a target="_blank" href="https://download.kortforsyningen.dk/content/vilk%C3%A5r-og-betingelser">Styrelsen for Dataforsyning og Effektivisering</a>'

    // Make the map object using the custom projection
    // proj4.defs('EPSG:25832', "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs");
    const crs = new this.$L.Proj.CRS(
      'EPSG:25832',
      '+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs',
      {
        resolutions: [
          1638.4, 819.2, 409.6, 204.8, 102.4, 51.2, 25.6, 12.8, 6.4, 3.2, 1.6,
          0.8, 0.4, 0.2,
        ],
        origin: [120000, 6500000],
        bounds: this.$L.bounds([120000, 5661139.2], [1378291.2, 6500000]),
      }
    )

    // Make the map object using the custom projection
    const map = new this.$L.Map(this.$refs.map, {
      crs,
      continuousWorld: true,
      center: [55.709155, 11.459081], // Set center location
      zoom: 9, // Set zoom level
      minzoom: 0,
      maxzoom: 13,
      zoomControl: this.controls,
    })
    this.$options.map = map
    this.setAdresse()
    this.setSkoler()
    this.setSkole()
    this.setRoute()

    // Define layers
    // Ortofoto [WMTS:orto_foraar]
    const ortofoto = this.$L.tileLayer(
      'https://services.kortforsyningen.dk/orto_foraar?token=' +
        kftoken +
        '&request=GetTile&version=1.0.0&service=WMTS&Layer=orto_foraar&style=default&format=image/jpeg&TileMatrixSet=View1&TileMatrix={zoom}&TileRow={y}&TileCol={x}',
      {
        minZoom: 0,
        maxZoom: 13,
        attribution: myAttributionText,
        crossOrigin: true,
        zoom() {
          const zoomlevel = map._animateToZoom
            ? map._animateToZoom
            : map.getZoom()
          if (zoomlevel < 10) return 'L0' + zoomlevel
          else return 'L' + zoomlevel
        },
      }
    )

    // Skærmkort [WMTS:topo_skaermkort]
    const skaermkort = this.$L
      .tileLayer(
        `https://api.dataforsyningen.dk/service?servicename=topo_skaermkort_daempet&token=${kftoken}&request=GetTile&version=1.0.0&service=WMTS&Layer=dtk_skaermkort_daempet&style=default&format=image/jpeg&TileMatrixSet=View1&TileMatrix={zoom}&TileRow={y}&TileCol={x}`,
        {
          minZoom: 0,
          maxZoom: 13,
          attribution: myAttributionText,
          crossOrigin: true,
          zoom(data) {
            const zoomlevel = data.z
            if (zoomlevel < 10) return 'L0' + zoomlevel
            else return 'L' + zoomlevel
          },
        }
      )
      .addTo(map)

    // Define layer groups for layer control
    const baseLayers = {
      'Topografisk kort': skaermkort,
      Flyfoto: ortofoto,
    }
    const overlays = {
      'Skoledistrikter 0.-6.klasse': skoledistrikter06,
      'Skoledistrikter 7.-9.klasse': skoledistrikter79,
      'Skoledistrikt 10.klasse': skoledistrikter10,
    }

    // Add layer control to map
    if (this.controls) this.$L.control.layers(baseLayers, overlays).addTo(map)

    // Add scale line to map
    this.$L.control.scale({ imperial: false }).addTo(map) // disable feet units
  },
  methods: {
    setRoute() {
      if (this.$options.route) {
        this.$options.map.removeLayer(this.$options.route)
      }
      if (this.route && this.route.length > 0) {
        this.$options.route = this.$L
          .polyline(this.route, {
            opacity: 0.5,
            weight: 5,
            color: 'red',
          })
          .addTo(this.$options.map)
        const bounds = this.$options.route.getBounds()
        if (this.$options.adresse)
          bounds.extend(this.$options.adresse.getLatLng())
        if (this.$options.skole) bounds.extend(this.$options.skole.getLatLng())
        this.$options.map.fitBounds(bounds, {
          padding: [10, 10],
        })
      }
    },
    setSkole() {
      if (this.$options.skole) {
        this.$options.map.removeLayer(this.$options.skole)
      }
      const val = this.skole
      if (val) {
        this.$options.skole = this.$L
          .marker(this.$L.latLng(val.coordinates[1], val.coordinates[0]), {
            icon: this.$L.MakiMarkers.icon({
              icon: 'school',
              color: '#4daf4a',
              size: 'l',
            }),
          })
          .addTo(this.$options.map)
        this.$options.skole.bindPopup(val.text)
      }
    },
    setSkoler() {
      if (this.$options.skoler) {
        this.$options.map.removeLayer(this.$options.skoler)
      }

      const icon = this.$L.MakiMarkers.icon({
        icon: 'school',
        color: '#377eb8',
        size: 'm',
      })

      this.$options.skoler = this.$L
        .geoJson(this.skoler, {
          pointToLayer: (feature, latlng) => {
            return this.$L.marker(latlng, { icon })
          },
          onEachFeature(feature, layer) {
            layer.bindPopup(feature.properties.Tekst)
          },
        })
        .addTo(this.$options.map)
      const bounds = this.$options.skoler.getBounds()
      if (this.$options.adresse)
        bounds.extend(this.$options.adresse.getLatLng())

      this.$options.map.fitBounds(bounds, {
        padding: [10, 10],
      })
    },
    setAdresse() {
      if (this.$options.adresse) {
        this.$options.map.removeLayer(this.$options.adresse)
      }
      const val = this.adresse
      if (val && val.type !== 'vejnavn') {
        this.$options.adresse = this.$L
          .marker(this.$L.latLng(val.data.y, val.data.x), {
            icon: this.$L.MakiMarkers.icon({
              icon: 'building',
              color: '#e41a1c',
              size: 'l',
            }),
          })
          .addTo(this.$options.map)
        this.$options.adresse.bindPopup(val.tekst)
        this.$options.adresse.openPopup()
      }
    },
  },
}
</script>

<style>
.map {
  width: 100%;
  height: 100%;
}
</style>
