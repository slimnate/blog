function initStlViewer() {

    //Define rotations for custom orientations
    orientations = {
        top: [0,0,0],
        front: [-3.14/2, 0, 0],
        right: [-3.14/2, -3.14/2, 0],
        left: [-3.14/2, 3.14/2, 0],
        iso: [-3.14/4, 0, -3.14/4],
    }

    //get each 3d-model element on the page
    var $modelElements = $("div.3d-model");
    $modelElements.each(function (i, elem) {
        //get file path attribute from element
        var filePath = $(elem).data('src');
        var color = $(elem).data('color').trim();
        var bg = $(elem).data('bg').trim();
        var orientation = $(elem).data('orientation');
        var viewer;

        console.log('Initing 3D File: ' + filePath);
        console.log('color: ' + color);
        console.log('bg: ' + bg);
        console.log('orientation: ' + orientation);

        // Callback to update custom data params after models load
        var models_loaded = function(id) {
            //update bg color
            if(bg != ''){
                viewer.set_bg_color(id, bg);
            }
        };

        // set model color
        if (color == ''){
            color = null;
        }

        // set model rotation
        var r_x=0, r_y=0, r_z=0;
        if (orientation != ''){
            //check for valid orientation
            if(Object.keys(orientations).indexOf(orientation) == -1){
                console.log('Error - Unknown orientation: "' + orientation + '"');
            }else {
                //perform rotation
                var rotations = orientations[orientation];
                r_x = rotations[0];
                r_y = rotations[1];
                r_z = rotations[2];
            }
        }

        //create new viewer
        viewer = new StlViewer(elem,
            {
                model_loaded_callback: models_loaded,
                models: [
                    {
                        id: 1,
                        filename: filePath,
                        color: color,
                        view_edges: true,
                        display: 'smooth',
                        rotationx: r_x,
                        rotationy: r_y,
                        rotationz: r_z,
                    }
                ] 
            }
        );
        viewers.push(viewer);
    });
}

viewers = [];

$().ready(initStlViewer);
