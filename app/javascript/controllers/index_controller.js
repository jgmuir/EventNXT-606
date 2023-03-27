import { Controller } from "@hotwired/stimulus"

export default class IndexController extends Controller {
  static targets = [ 'dom', 'template', 'limit', 'offset', 'maxcount' ];
  static values = { url: String, offset: Number, limit: { type: Number, default: 10 }, countofrec: Number};

  connect() { 
    if(this.urlValue.match("guests") || this.urlValue.match("sale_tickets")) 
      this.getCount();
    this.query(); 
  }

  getCount(){
    fetch(`${this.urlValue}/count_all`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token")
      }
    }).then(response => response.json())
      .then(data => {this.countofrecValue = data;this.setmaxcount()})
  }

  setmaxcount(){
      let elem = this.maxcountTarget.querySelector(`[data-nxt-maxcount]`);
      elem.innerHTML = this.offsetValue + " - " + Math.min(this.offsetValue+this.limitValue,this.countofrecValue) + " of " + this.countofrecValue;
  }

  query() {
    let params = new URLSearchParams({
      offset: this.offsetValue,
      limit: this.limitValue
    })
    fetch(`${this.urlValue}?${params.toString()}`, {
      headers: {
        "Authorization": "Bearer " + localStorage.getItem("access_token")
      }
    }).then(response => response.json())
      .then(data => {
          this.preProcess();
          this.domTarget.innerHTML = '';
          if (Array.isArray(data))
            for (const d of data)
              this.domTarget.appendChild(this.display(d))
          else
            this.domTarget.appendChild(this.display(data))
          this.postProcess();
      })
  }

  preProcess() {}

  postProcess() {}

  display(obj) {
    const template = this.templateTarget.content.cloneNode(true);
    return this.fillTemplate(obj, template);
  }
  
  requery(e) {
    let target = e.currentTarget;
    let idDom = target.querySelector('.id');
    if (idDom === null)
      return;
    let id;
    if (idDom.tagName === "INPUT" || idDom.tagName === "BUTTON") {
      id = idDom.value
    } else {
      id = idDom.textContent;
    }

    fetch(`${this.urlValue}/${id}`)
      .then(response => response.json())
      .then(data => {
          for (const field of e.params['fields']) {
            let result = data[field];
            let elems = target.querySelectorAll(`.${field}`);
            if (elems === null)
              continue;
            elems.forEach( elem => {
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
        });
  }

  fillTemplateArray(arr, template) {
    let result = '';
    for (const elem of arr) {
      let freshTemplate = template.firstElementChild.cloneNode(true);
      let node = this.fillTemplate(elem, freshTemplate);
      result += node.innerHTML;
    }
    return result;
  }

  fillTemplate(obj, template) {
    for (const [key, value] of Object.entries(obj)) {
      let result;
      if (typeof value === 'object' && value !== null) {
        const nestedTemplate = this.element.querySelector(`template#${key}`).content.cloneNode(true);
        if (nestedTemplate === null)
          continue;
        if (Array.isArray(value)) {
          result = this.fillTemplateArray(value, nestedTemplate);
        } else {
          result = this.fillTemplate(value, nestedTemplate);
        }
      } else {
        result = value;
      }

      const elems = template.querySelectorAll(`[data-nxt-${key}]`)
      if (elems === null)
        continue;
      elems.forEach( elem => {
        if (result !== null){
          if (typeof(result) == "string") { // edit date into normal format using JS
            if(result.includes(":")){
              var split = result.split("T")
              result = split[0]
            }
          }
          elem.setAttribute(`data-nxt-${key}`, result)
        }

        if (elem.getAttribute('data-nxt-nomod') !== null)
          return;

        if (elem.tagName === "INPUT"
              || elem.tagName === 'SELECT'
              || elem.tagName === 'BUTTON') {
          if (elem.type == 'checkbox' && typeof result == 'boolean') {
            elem.value = key;
            elem.checked = value;
          } else if (elem.type == 'number') {
            elem.setAttribute('value', result);
          } else {
            elem.value = result;
          }
        } else if (elem.tagName === "IMG") {
          if (result !== null)
            elem.src = result;
        } else if (elem.tagName === "A") {
          if (result !== null)
            elem.href = result;
          else
            elem.classList.add("disabled");
        } else {
          elem.innerHTML = result;
        }
      });

      if (key === 'id') {
        let elems = template.querySelectorAll('a[data-nxt-link_]');
        elems.forEach( elem => {
          elem.href = `${window.location.href}/${value}`
        });
      }
    }
    return template;
  }

  updateLimit() {
    if (this.hasLimitTarget){
      this.limitValue = this.limitTarget.value
      this.setmaxcount();
      this.query();
    }
  }

  incrementOffset() {
    // limit offset based on total number of records in table
    if((this.offsetValue+this.limitValue)<this.countofrecValue){
      this.offsetValue += this.limitValue;
      this.setmaxcount();
      this.query();
    }
  }

  decrementOffset() {
    this.offsetValue = Math.max(this.offsetValue - this.limitValue, 0)
    this.setmaxcount();
    this.query();
  }
  
  updateOffset() {
    if (this.hasOffsetTarget)
      this.limitValue = this.offsetTarget.value
  }

  limitValueChanged(value, previousValue) {
    if (value != previousValue)
      this.query();
  }

  offsetValueChanged(value, previousValue) {
    if (value != previousValue)
      this.query()
  }
}