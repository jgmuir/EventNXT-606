import IndexController from "controllers/index_controller";

export default class GuestController extends IndexController {
  static targets = [ 'add', 'seat', 'tooltip' ];
  static values = { seaturl: String };

  query() {
    super.query();
  }

  preProcess() {
    this.headers = this.domTarget.firstElementChild.cloneNode(true)
    // this.add = this.domTarget.lastElementChild.cloneNode(true)
  }

  postProcess() {
    // this.setupForms()
    this.genNoGuestMessage()
    this.domTarget.prepend(this.headers);
    // this.domTarget.append(this.add);

    this.genTooltips();
    this.handleBookStatus();
    this.handleAddedBy();
    this.updateSeats();
  }

  setupForms() {
    let trs = this.domTarget.querySelectorAll('tr')
    for (const tr of trs) {
      let form = tr.querySelector('form[data-nxt-id]')
      form.id = `form-${form.getAttribute('data-nxt-id')}`
      let formid = form.id
      
      let inputs = tr.querySelectorAll('[name]')
      for (const input of inputs)
        input.setAttribute('form', formid)
    }
  }

  genNoGuestMessage() {
    if (this.domTarget.childElementCount != 0)
      return;

    let rowDiv = document.createElement('div')
    let colDiv = document.createElement('div')
    let msg = document.createTextNode('No guests.')
    rowDiv.classList.add('row')
    colDiv.classList.add('col-lg')
    colDiv.classList.add('text-center')
    colDiv.append(msg)
    rowDiv.append(colDiv)
    this.domTarget.append(rowDiv)
  }

  genTooltips() {
    for (const dom of this.tooltipTargets) {
      if (dom.childNodes.length === 0) {
        dom.remove();
        continue;
      }

      //let tooltip = new bootstrap.Tooltip(dom, {boundary: document.body});
      dom.setAttribute('data-bs-toggle', 'tooltip');
      dom.setAttribute('data-bs-placement', 'top');
      dom.title = dom.textContent;
      dom.textContent = '';
    }
  }

  handleBookStatus() {
    for (const dom of this.element.querySelectorAll('i[data-nxt-booked]')) {
      if (dom.textContent === 'false')
        dom.remove();
      else {
        dom.textContent = '';
        dom.title = 'booked';
      }
    }
  }

  handleAddedBy() {
    for (const dom of this.element.querySelectorAll('p[data-nxt-added_by]')) {
      fetch(`/api/v1/users/${dom.textContent}`)
        .then(response => response.json())
        .then(data => {
          dom.textContent = `${data['first_name']} ${data['last_name']}`
        })
    }
  }

  resetAddGuest() {
    this.addTarget.reset()
  }

  updateForm(e) {
    let form = e.currentTarget
    let selectSeat = form.querySelector('select[data-nxt-category]')
    let guestId = form.querySelector('input[data-nxt-id]').value
    let inputAllotted = form.querySelector('input[data-nxt-allotted]')

    // update the allotted input after selecting seat tier
    if (e.target.tagName === 'SELECT' && e.target.name === 'seat_id') {
      let seatId = selectSeat.value
      if (seatId) {
        inputAllotted.disabled = false;
        fetch(`${this.urlValue}/${guestId}/tickets?seat_id=${seatId}`)
          .then(response => response.json())
          .then(data => {
            if (data.length == 0) {
              inputAllotted.value = 0
              return
            }

            for (const [_, ticket] of Object.entries(data)) {
              if (ticket['allotted'])
                inputAllotted.value = ticket['allotted'];
              else
                inputAllotted.value = 0;
            }
          })
      } else {
        inputAllotted.value = '';
        inputAllotted.disabled = true;
      }
    } else {
      let fd = new FormData(form);
      fd.set('checked', fd.get('checked') ? true : false);

      // update guest info
      let guestData = new FormData();
      guestData.append('id', fd.get('id'))
      guestData.append('affiliation', fd.get('affiliation'))
      guestData.append('checked', fd.get('checked'))
      fetch(`${this.urlValue}/${guestId}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('access_token')}`
        },
        method: 'PATCH',
        body: guestData
      })
        .then(response => response.json())

      // update ticket allotment
      if (fd.get('seat_id') !== '') {
        let ticketData = new FormData();
        ticketData.append('seat_id', fd.get('seat_id'));
        ticketData.append('allotted', fd.get('allotted'));
        fetch(`${this.urlValue}/${guestId}/tickets`, {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('access_token')}`
          },
          method: 'PATCH',
          body: ticketData
        })
          .then(response => response.json())
      }
    }
  }

  updateSeats() {
    fetch(`${this.seaturlValue}`)
      .then(response => response.json())
      .then(data => {

        let selects = this.seatTargets
        for (const select of selects) {
          let opts = [];
          opts.push(new Option())
          for (const dat of data)
            opts.push(new Option(dat['category'], dat['id'], false, false));

          select.innerHTML = '';
          for (const opt of opts) {
            select.add(opt)
            if (select.getAttribute('data-nxt-category') === opt.value)
              opt.setAttribute('selected', true)
          }
        }
      });
  }
}