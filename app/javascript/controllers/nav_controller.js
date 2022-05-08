import { Controller } from "@hotwired/stimulus"

export default class NavController extends Controller {
  connect() {
    // should have dedicated profile hook
    fetch('/api/v1/users', {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('access_token')}`
      }
    }).then(response => {
        if (response.ok) {
          this.insertAdmin()
        }
      })
  }

  insertAdmin() {
    let a = document.createElement('a')
    a.classList.add('nav-link')
    a.setAttribute('href', '/admin')
    a.textContent = 'Admin Portal'
    this.element.append(a)
  }
}