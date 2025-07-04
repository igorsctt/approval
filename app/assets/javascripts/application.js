//= require_tree .
//= require_self

// Application JavaScript
document.addEventListener('DOMContentLoaded', function() {
  console.log('Approval Workflow System loaded');
  
  // Auto-hide alerts after 5 seconds
  const alerts = document.querySelectorAll('.alert');
  alerts.forEach(alert => {
    setTimeout(() => {
      alert.style.opacity = '0';
      setTimeout(() => {
        alert.remove();
      }, 300);
    }, 5000);
  });
});
