import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 'template', 'dom', 'update' ];
  static values = { url: String };

  sendFromForm(e) {
    e.preventDefault();
    let form = e.currentTarget;
    if (!form.checkValidity())
      return;

    let payload = new FormData(form);
    payload.delete('id')
    payload.delete('access_token');
    payload.delete('authenticity_token');

    let id = form.querySelector('.id');
    if (!id || id.value === '')
      this.create(payload);
    else
      this.update(payload, id.value);
  }

  updateBatchFromCheckbox({ params: { payload } }) {
    if (this.updateTargets.length > 0) {
      this.updateTargets.forEach( elem => {
        let checkbox = elem.querySelector('input[type="checkbox"].id');
        if (!checkbox.checked) 
          return;
        fetch(`${this.urlValue}/${checkbox.value}`, {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('access_token')}`,
            'content-type': 'application/json'
          },
          method: 'PATCH',
          body: JSON.stringify(payload)
        }).then(response => response.json())
          .then(data => {
          elem.replaceWith(this.fillTemplate(data, elem));
        });
        checkbox.checked = false;
      })
    }
  }

  create(payload) {
    fetch(`${this.urlValue}`, {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('access_token')}`,
      },
      method: 'POST',
      body: payload
    }).then(response => response.json())
      .then(data => this.dispatch('created', {detail: data}))
  }

  update(payload, id) {
    fetch(`${this.urlValue}/${id}`, {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('access_token')}`,
      },
      method: 'PATCH',
      body: payload
    }).then(response => response.json())
      .then(data => this.dispatch('updated', {detail: data}))

  }

  fillTemplate(obj, template) {
    for (const [key, value] of Object.entries(obj)) {
      console.log(key, value);
      let result;
      if (Array.isArray(value)) {
        const nestedTemplate = this.element.querySelector(`#${key}`).content.cloneNode(true);
        if (nestedTemplate === null)
          continue;
        console.log(nestedTemplate);
        result += this.fillTemplateArray(value, nestedTemplate);
      } else if (typeof value === 'object' && value != null) {
        const nestedTemplate = this.element.querySelector(`#${key}`).content.cloneNode(true);
        if (nestedTemplate === null)
          continue;
        result = this.fillTemplate(value, nestedTemplate);
      } else {
        result = value;
      }
      const elems = template.querySelectorAll(`.${key}`)
      if (elems !== null)
        elems.forEach( elem => {
          console.log(elem);
          if (elem.tagName === "INPUT"
                || elem.tagName === 'SELECT'
                || elem.tagName === 'BUTTON') {
            if (elem.type == 'checkbox' && typeof result == 'boolean') {
              elem.value = key
              elem.checked = value
            } else {
              elem.value = result;
            }
          } else {
            elem.innerHTML = result;
          }
        });
    }
    return template;
  }
}