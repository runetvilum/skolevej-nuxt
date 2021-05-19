<template>
  <v-app>
    <v-main>
      <v-container fluid>
        <v-alert v-show="step === 4" color="info" text outlined>
          <h3>Du har valgt</h3>
          <v-list>
            <v-list-item>
              <v-list-item-action>
                <v-icon color="info">mdi-map-marker</v-icon>
              </v-list-item-action>
              <v-list-item-content class="info--text">
                {{ adresse && adresse.tekst }}
              </v-list-item-content>
            </v-list-item>
            <v-list-item>
              <v-list-item-action>
                <v-icon color="info">mdi-account</v-icon>
              </v-list-item-action>
              <v-list-item-content class="info--text">
                {{ klasse && klasse.text }}
              </v-list-item-content>
            </v-list-item>
            <v-list-item>
              <v-list-item-action>
                <v-icon color="info">mdi-school</v-icon>
              </v-list-item-action>
              <v-list-item-content class="info--text">
                {{ skole && skole.text }}
              </v-list-item-content>
            </v-list-item>
            <v-list-item>
              <v-list-item-action>
                <v-icon color="info">mdi-bus-school</v-icon>
              </v-list-item-action>
              <v-list-item-content class="info--text">
                {{ transport && transport.text }}
              </v-list-item-content>
            </v-list-item>
          </v-list>
          <v-divider class="my-4 info" />
          <h3>
            {{ `Afstand ${afstand}` }}
          </h3>
        </v-alert>
        <v-alert v-if="tilskud && !err" color="success" outlined text>
          <v-row align="center" no-gutters>
            <v-col class="grow">
              <h3 v-if="farlig">
                Du er berettiget til at søge transport, da der er trafikfarlige
                veje på din skolevej!
              </h3>
              <h3 v-else>Du er berettiget til at søge transport!</h3>
            </v-col>
            <v-col class="shrink">
              <v-btn
                color="success"
                :href="`https://trafik.os2geo.dk/?adresse=${
                  adresse && (adresse.data.adgangsadresseid || adresse.data.id)
                }&klasse=${klasse && klasse.value}&skole=${
                  skole && skole.value
                }&transport=${transport.value}`"
                target="_blank"
              >
                Åbn
              </v-btn>
            </v-col>
          </v-row>
        </v-alert>
        <v-alert v-if="!tilskud && !err" color="error" text outlined>
          <h3>Du er ikke berettiget til at søge transport!</h3>
        </v-alert>
        <v-alert v-if="err" type="error" text outlined>
          <h3>Der kan ikke beregnes en rute</h3>
        </v-alert>
        <no-ssr>
          <c-map
            :adresse="adresse"
            :skoler="skolerGeoJSON"
            :skole="skole"
            :route="route"
            style="height: 500px"
          />
        </no-ssr>
      </v-container>
    </v-main>
  </v-app>
</template>

<script>
import { booleanPointInPolygon, point } from '@turf/turf'
import skoleDistrikter from '~/components/Skoledistrikter/Skoledistrikt_0-6.json'
import skolerData from '~/components/skoler.json'

export default {
  data() {
    return {
      farlig: false,
      err: null,
      skoleDistrikt: null,
      step: 1,
      tid: null,
      tilskud: false,
      afstand: null,
      adresser: [],
      search: null,
      adresse: null,
      skole: null,
      klasse: null,
      route: null,
      transports: [
        {
          text: 'Cykel',
          value: 'bicycle',
        },
        {
          text: 'Til fods',
          value: 'foot',
        },
      ],
      transport: null,
      klasser: [
        {
          text: '0. klasse',
          value: 0,
        },
        {
          text: '1. klasse',
          value: 1,
        },
        {
          text: '2. klasse',
          value: 2,
        },
        {
          text: '3. klasse',
          value: 3,
        },
        {
          text: '4. klasse',
          value: 4,
        },
        {
          text: '5. klasse',
          value: 5,
        },
        {
          text: '6. klasse',
          value: 6,
        },
        {
          text: '7. klasse',
          value: 7,
        },
        {
          text: '8. klasse',
          value: 8,
        },
        {
          text: '9. klasse',
          value: 9,
        },
        {
          text: '10. klasse',
          value: 10,
        },
      ],
    }
  },
  computed: {
    skoler() {
      return this.skolerFilter.map((item) => {
        return {
          text: item.properties.Tekst,
          value: item.properties.id,
          coordinates: item.geometry.coordinates,
        }
      })
    },
    skolerGeoJSON() {
      return {
        type: 'FeatureCollection',
        features: this.skolerFilter,
      }
    },
    skolerFilter() {
      return skolerData.features.filter((item) => {
        return (
          this.skoleDistrikt === null ||
          (item.properties.distrikt.includes(this.skoleDistrikt) &&
            item.properties.klasse.includes(this.klasse.value))
        )
      })
    },
  },

  watch: {
    search(val) {
      val && this.query(val)
    },
  },
  async mounted() {
    this.transport = this.transports[0]
    const query = this.$route.query
    if (query.adresse && query.klasse && query.skole && query.transport) {
      const res = await this.$axios.get(
        `https://api.dataforsyningen.dk/adgangsadresser/${query.adresse}`
      )
      this.adresse = {
        tekst: res.data.adressebetegnelse,
        data: {
          adgangsadresseid: res.data.id,
          x: res.data.adgangspunkt.koordinater[0],
          y: res.data.adgangspunkt.koordinater[1],
        },
      }
      this.adresser = [this.adresse]
      this.klasse = this.klasser[query.klasse]
      this.klasseChanged(this.klasse)
      this.transport = this.transports.find(
        (item) => item.value === query.transport
      )
      this.skole = this.skoler.find(
        (item) => item.value === Number(query.skole)
      )
      this.skoleChanged(this.skole)
    }
  },
  methods: {
    decode(encoded, precision) {
      precision = Math.pow(10, -precision)
      const len = encoded.length
      let index = 0
      let lat = 0
      let lng = 0
      const array = []
      while (index < len) {
        let b
        let shift = 0
        let result = 0
        do {
          b = encoded.charCodeAt(index++) - 63
          result |= (b & 0x1f) << shift
          shift += 5
        } while (b >= 0x20)
        const dlat = result & 1 ? ~(result >> 1) : result >> 1
        lat += dlat
        shift = 0
        result = 0
        do {
          b = encoded.charCodeAt(index++) - 63
          result |= (b & 0x1f) << shift
          shift += 5
        } while (b >= 0x20)
        const dlng = result & 1 ? ~(result >> 1) : result >> 1
        lng += dlng
        // array.push( {lat: lat * precision, lng: lng * precision} );
        array.push([lat * precision, lng * precision])
      }
      return array
    },
    toHHMMSS(val) {
      let seconds = Math.floor(val)
      let hours = Math.floor(seconds / 3600)
      seconds -= hours * 3600
      let minutes = Math.floor(seconds / 60)
      seconds -= minutes * 60

      if (hours < 10) {
        hours = '0' + hours
      }
      if (minutes < 10) {
        minutes = '0' + minutes
      }
      if (seconds < 10) {
        seconds = '0' + seconds
      }
      return hours + ':' + minutes + ':' + seconds
    },
    async adresseChanged(val) {
      if (val) {
        if (val.type === 'vejnavn') {
          await this.query(val.tekst)
          this.$refs.adresse.isMenuActive = true
        } else {
          this.step = 2
        }
      }
      this.skoleDistrikt = null
      this.klasse = null
      this.skole = null
      this.route = null
    },
    async query(v) {
      const res = await this.$axios.get(
        `https://api.dataforsyningen.dk/autocomplete?q=${this.search}&kommunekode=0217&`
      )
      this.adresser = res.data
    },
    klasseChanged(val) {
      if (val) {
        const p = point([this.adresse.data.x, this.adresse.data.y])
        const skoledistrikt = skoleDistrikter.features.find((item) => {
          return booleanPointInPolygon(p, item)
        })
        this.skoleDistrikt = skoledistrikt
          ? skoledistrikt.properties.DISTRIKT
          : null
        this.step = 3
        this.skole = null
        this.route = null
      }
    },
    skoleChanged(val) {
      if (val) {
        this.getRoute()
        this.step = 4
      }
      this.route = null
    },
    transportChanged(val) {
      this.getRoute()
    },
    async getRoute() {
      try {
        this.err = null
        const res = await this.$axios.post('/api/route', {
          klasse: this.klasse.value,
          transport: this.transport.value,
          coordinates: [
            [this.adresse.data.x, this.adresse.data.y],
            this.skole.coordinates,
          ],
        })
        const route = res.data.routes[0]
        this.tid = this.toHHMMSS(route.duration)
        this.afstand =
          route.distance >= 1000
            ? `${(route.distance / 1000).toLocaleString(undefined, {
                maximumFractionDigits: 3,
              })} km`
            : `${route.distance.toLocaleString(undefined, {
                maximumFractionDigits: 1,
              })} m`
        let data = []
        route.legs[0].steps.forEach((item) => {
          const coor = this.decode(item.geometry, 6)
          data = [...data, ...coor]
        })
        this.route = data
        this.tilskud = res.data.tilskud
        this.farlig = res.data.farlig
      } catch (err) {
        this.err = true
        this.afstand = '0'
        this.route = null
      }
    },
  },
}
</script>
<style scoped>
.map2 {
  height: 300px;
}
.map1 {
  height: 100%;
}
</style>
