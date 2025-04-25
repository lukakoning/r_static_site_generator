// www/js/scripts.js
$(document).ready(function(){
  $('.image-slider').slick({
    dots: true,          // Show dots navigation
    infinite: true,      // Loop slides
    speed: 500,          // Transition speed (ms)
    fade: true,          // Use fade effect
    cssEase: 'linear',   // CSS easing for fade
    autoplay: true,      // Autoplay slides
    autoplaySpeed: 3000  // Time between slides (ms)
  });
});
