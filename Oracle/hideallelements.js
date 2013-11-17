<script type="text/javascript">
jQuery(document).ready(function() {
	jQuery(":not(div.entry)").hide(); jQuery(":has(div.entry)").show(); jQuery("div.entry *").show(); jQuery("#container").css("background-image", "none").css("padding", "0px").css("margin", "0px"); jQuery(":has(.post)").css("padding", "0px").css("margin", "0px"); jQuery(":has(div.entry), div.entry").css("width", "100%").css("background", "").css("background-color", "#fff"); jQuery("#socialbuttons").hide(); jQuery("a[href]").removeAttr("href"); jQuery("html,head,body").css("width", "");
});
</script>
// JO_END_EXECUTABLE - nothing will execute beyond this line

// Hide all elements on a page except for the content
// Copyright 2013 Josh Oldenburg

alert("magic!");

/*jQuery(":not(div.entry)").hide();
jQuery(document).ready(function() {
	jQuery(":not(:has(div.entry))").hide();
	alert("Magic!");
}); */
// jQuery(":not(div.entry)").hide(); jQuery(":has(div.entry)").show(); jQuery("div.entry *").show(); jQuery("#container").css("background-image", "none").css("padding", "0px").css("margin", "0px"); jQuery(":has(.post)").css("padding", "0px").css("margin", "0px"); jQuery(":has(div.entry), div.entry").css("width", "100%");
