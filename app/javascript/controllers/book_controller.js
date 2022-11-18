import IndexController from "controllers/index_controller";

export default class BookController extends IndexController {
  static targets = [ 'form', 'submit' ]
  static values = { eventid: Number, guestid: Number }

  preProcess() {
    this.submit = this.formTarget.firstElementChild.cloneNode(true)
  }

  postProcess() {
    this.formTarget.append(this.submit)
    this.handleSeatCategory()
    this.handleMaxCommittment()
    this.showExpiry()
  }

  showExpiry() {
    let guestData = new FormData();
    guestData.append('guest_id', this.guestidValue)
    fetch(`/api/v1/guest/get_expired`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token"),
      },
      method: "POST",
      body: guestData
    }).then(response => response.json())
    .then(data => {
      console.log(data)
      if(data){
      let bookDom = document.getElementById("book")
      bookDom.innerHTML = "<br><br><h3>The RSVP link has expired. Please go to the FashioNXT events page to book the tickets.</h3>"
      }
    })
  }

  handleSeatCategory() {
    for (const form of this.formTargets) {
      let seatId = form.querySelector('input[data-nxt-seat_id]').value
      let categoryDom = form.querySelector('input[data-nxt-category]')
      fetch(`/api/v1/events/${this.eventidValue}/seats/${seatId}`)
        .then(response => response.json())
        .then(data => {
          categoryDom.value = data['category']
        })
    }
  }

  handleMaxCommittment() {
    for (const form of this.formTargets) {
      let inputCommitted = form.querySelector('input[data-nxt-committed]')
      let maxAllotted = form.querySelector('[data-nxt-allotted]').getAttribute('data-nxt-allotted')
      inputCommitted.setAttribute('max', maxAllotted)
    }
  }

  sendTickets(e) {
    e.preventDefault()
    let fd = new FormData(this.formTarget)
    fetch(`/api/v1/events/${this.eventidValue}/guests/${this.guestidValue}/book`, {
      method: 'PATCH',
      body: fd
    }).then(response => {
      if (response.ok) {
        this.disableSubmit()
      }
    })
  }

  disableSubmit() {
    this.submitTarget.textContent = 'Submitted'
    this.submitTarget.disabled = true
  }

}