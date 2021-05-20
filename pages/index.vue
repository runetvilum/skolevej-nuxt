<template>
  <v-app>
    <v-main>
      <v-container class="fill-height pa-0" fluid>
        <v-row class="fill-height" no-gutters>
          <v-col cols="12" sm="6" md="5" lg="4" xl="3">
            <v-stepper v-model="step" vertical flat>
              <v-stepper-step
                step="1"
                complete-icon="mdi-map-marker"
                complete
                >{{ adresseLabel }}</v-stepper-step
              >
              <v-stepper-content step="1">
                <v-autocomplete
                  ref="adresse"
                  v-model="adresse"
                  :loading="loading"
                  :items="adresser"
                  :search-input.sync="search"
                  hide-no-data
                  clearable
                  item-text="tekst"
                  label="Indtast din adresse"
                  placeholder="vejnavn, husnr, postnr"
                  return-object
                  @change="adresseChanged"
                />
                <v-btn v-show="adresse" color="primary" @click="step = 2"
                  >Næste</v-btn
                >
              </v-stepper-content>
              <v-stepper-step step="2" complete-icon="mdi-account" complete>{{
                klasseLabel
              }}</v-stepper-step>
              <v-stepper-content step="2">
                <v-select
                  v-model="klasse"
                  :items="klasser"
                  label="Klassetrin"
                  return-object
                  @change="klasseChanged"
                />
                <v-btn text @click="step = 1">Forrige</v-btn>
                <v-btn v-show="klasse" color="primary" @click="step = 3"
                  >Næste</v-btn
                >
              </v-stepper-content>
              <v-stepper-step step="3" complete-icon="mdi-school" complete>{{
                skoleLabel
              }}</v-stepper-step>
              <v-stepper-content step="3">
                <v-select
                  v-model="skole"
                  :items="skoler"
                  label="Skole"
                  return-object
                  @change="skoleChanged"
                />
                <v-btn text @click="step = 2">Forrige</v-btn>
                <v-btn v-show="skole" color="primary" @click="step = 4"
                  >Næste</v-btn
                >
              </v-stepper-content>
              <v-stepper-step
                step="4"
                complete-icon="mdi-bus-school"
                complete
                >{{ transportLabel }}</v-stepper-step
              >
              <v-stepper-content step="4">
                <v-select
                  v-model="transport"
                  :items="transports"
                  label="Tansport"
                  return-object
                  @change="transportChanged"
                />
                <v-select
                  v-model="retning"
                  :items="retninger"
                  label="Retning"
                  return-object
                  @change="retningChanged"
                />

                <v-btn text @click="step = 3">Forrige</v-btn>
              </v-stepper-content>
            </v-stepper>
            <v-container>
              <v-alert v-show="step !== 4" color="info" text outlined>
                <h3>Vælg adresse, klassetrin, skole og transport</h3>
              </v-alert>
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
                      {{
                        `${transport && transport.text} ${
                          retning && retning.text
                        }`
                      }}
                    </v-list-item-content>
                  </v-list-item>
                </v-list>
                <v-divider class="my-4 info" />
                <h3>
                  {{ `Afstand ${afstand}` }}
                </h3>
              </v-alert>
              <v-alert
                v-if="step === 4 && tilskud && !err"
                color="success"
                outlined
                text
              >
                <h3 v-if="farlig">
                  Du er berettiget til at søge transport, da der er
                  trafikfarlige veje på din skolevej!
                </h3>
                <h3 v-else>Du er berettiget til at søge transport!</h3>

                <v-divider class="my-4 success" />
                <v-row align="center" no-gutters>
                  <v-col class="grow">
                    Gem ruteberegning som PDF og søg om transport
                  </v-col>
                  <v-col class="shrink">
                    <v-btn color="success" @click.prevent="save()"> Gem </v-btn>
                  </v-col>
                </v-row>
              </v-alert>
              <v-alert
                v-if="step === 4 && !tilskud && !err"
                color="error"
                text
                outlined
              >
                <h3>Du er ikke berettiget til at søge transport!</h3>
              </v-alert>
              <v-alert v-if="err" type="error" text outlined>
                <h3>Der kan ikke beregnes en rute</h3>
              </v-alert>
            </v-container>
          </v-col>
          <v-col
            cols="12"
            sm="6"
            md="7"
            lg="8"
            xl="9"
            :class="$vuetify.breakpoint.xs ? 'map2' : 'map1'"
          >
            <client-only>
              <c-map
                :adresse="adresse"
                :skoler="skolerGeoJSON"
                :skole="skole"
                :route="route"
                controls
              />
            </client-only>
          </v-col>
        </v-row>
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
      loading: false,
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
      retninger: [
        {
          text: 'Fra hjem til skole',
          value: 0,
        },
        {
          text: 'Fra skole til hjem',
          value: 1,
        },
      ],
      retning: null,
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
    adresseLabel() {
      return this.step !== 1 && this.adresse
        ? this.adresse.tekst
        : 'Vælg adresse'
    },
    klasseLabel() {
      return this.step !== 2 && this.klasse
        ? this.klasse.text
        : 'Vælg klassetrin'
    },
    skoleLabel() {
      return this.step !== 3 && this.skole ? this.skole.text : 'Vælg skole'
    },
    transportLabel() {
      return this.step !== 4 && this.transport && this.retning
        ? `${this.transport && this.transport.text} ${
            this.retning && this.retning.text
          }`
        : 'Vælg transport'
    },
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
    this.retning = this.retninger[0]
    const query = this.$route.query
    if (
      query.adresse &&
      query.klasse &&
      query.skole &&
      query.transport &&
      query.retning
    ) {
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
      this.retning = this.retninger.find(
        (item) => item.value === Number(query.retning)
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
      this.loading = true
      const res = await this.$axios.get(
        `https://api.dataforsyningen.dk/autocomplete?q=${this.search}&kommunekode=0217&`
      )
      this.adresser = res.data
      this.loading = false
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
    retningChanged(val) {
      this.getRoute()
    },
    save() {
      const url = `/api/pdf/${
        this.adresse.data.adgangsadresseid || this.adresse.data.id
      }/${this.klasse.value}/${this.skole.value}/${this.transport.value}/${
        this.retning.value
      }`
      // open download link in new page
      window.open(url)

      // redirect current page to success page
      window.location = 'https://selvbetjening.egki.dk/217/217-07031914163514'
      window.focus()
    },
    async getRoute() {
      try {
        this.err = null
        const res = await this.$axios.post('/api/route', {
          klasse: this.klasse.value,
          transport: this.transport.value,
          retning: this.retning.value,
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
