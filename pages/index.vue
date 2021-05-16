<template>
  <v-app>
    <v-app-bar app color="primary" dark>
      <v-toolbar-title>Ansøgning om kørselstilskud</v-toolbar-title>
    </v-app-bar>
    <v-main>
      <v-row>
        <v-col>
          <v-container>
            <v-form>
              <v-autocomplete
                ref="adresse"
                v-model="select"
                :loading="loading"
                :items="items"
                :search-input.sync="search"
                hide-no-data
                hide-details
                item-text="tekst"
                label="Indtast din adresse"
                placeholder="vejnavn, husnr, postnr"
                return-object
                @change="adresseChanged"
              />
              <v-select v-model="klasse" :items="klasser" />
            </v-form>
          </v-container>
        </v-col>
        <v-col>
          <div ref="map" />
        </v-col>
      </v-row>
    </v-main>
  </v-app>
</template>

<script>
export default {
  data() {
    return {
      loading: false,
      items: [],
      search: null,
      select: null,
      klasse: null,
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
  watch: {
    search(val) {
      val && val !== this.select && this.query(val)
    },
  },
  mounted() {},
  methods: {
    async adresseChanged(val) {
      if (val) {
        if (val.type === 'vejnavn') {
          await this.query(val.tekst)
          this.$refs.adresse.isMenuActive = true
        } else if (val.type === 'adresse') {
          console.log(val)
        }
        console.log(val)
      }
    },
    async query(v) {
      this.loading = true
      const res = await this.$axios.get(
        `https://api.dataforsyningen.dk/autocomplete?q=${this.search}`
      )
      this.items = res.data
      this.loading = false
    },
  },
}
</script>
<style scoped></style>
