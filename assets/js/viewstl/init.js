function initStlViewer() {
    //get each 3d-model element on the page
    var $modelElements = $("div.3d-model");
    $modelElements.each(function (i, elem) {
        //get file path attribute from element
        var filePath = $(elem).data('src');
        console.log('Initing 3D File: ' + filePath);
        //create new viewer
        new StlViewer(elem, { models: [{ filename: filePath }] });
    });
}

$().ready(initStlViewer);
