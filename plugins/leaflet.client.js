import * as L from 'leaflet'
// import 'proj4'
import 'proj4leaflet'
import 'leaflet/dist/leaflet.css'
import 'leaflet-makimarkers'
export default ({ app }, inject) => {
  inject('L', L)
}
