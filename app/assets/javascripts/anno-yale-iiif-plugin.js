
function split( val ) {
    return val.split( /\s+/ );
}
function extractLast( term ) {
    return split( term ).pop();
}

/**
 * A simple storage connector plugin to the ElasticSearch REST interface.
 *
 * Note: the plugin requires jQuery to be linked into the host page.
 *
 * THIS PLUGIN IS FOR DEMO PURPOSES ONLY - DON'T USE IN A PRODUCTION
 * ENVIRONMENT.
 */
annotorious.plugin.YaleIIIF = function(opt_config_options) {

    /** @private **/
    this._annotations = [];

    /** @private **/
    this._loadIndicators = [];
}

annotorious.plugin.YaleIIIF.prototype.reset = function(opt_config_options) {

    /** @private **/
    this._PROJECT_ID = opt_config_options['project_id'];

    /** @private **/
    this._STORE_URI = opt_config_options['base_url'];

    /** @private **/
    this._CANVAS_HEIGHT = opt_config_options['canvas_height'];

    /** @private **/
    this._MANIFEST_URI = opt_config_options['manifest_uri'];

    /** @private **/
    this._MANIFEST_LABEL = opt_config_options['manifest_label'];

    /** @private **/
    this._CANVAS_URI = opt_config_options['canvas_uri'];

    /** @private **/
    this._CANVAS_LABEL = opt_config_options['canvas_label'];

    /** @private **/
    this._IMAGE_ANNOTATION_LISTS = opt_config_options['annotation_lists'];

    /** @private **/
    this._annotations = [];

    /** @private **/
    this._loadIndicators = [];
}

annotorious.plugin.YaleIIIF.prototype.onEditorShown = function(annotation) {
    /** TODO: move to configuration parameter **/

    if (yale_iiif_show_autocomplete) {
        console.log("Adding autocomplete handler");
        jQuery(".annotorious-editor-text")
            .autocomplete({
                source: function (request, response) {
                    $.ajax({
                        url:  yale_iiif_autocomplete_url,
                        data: {term: extractLast(request.term)},
                        dataType: "json",
                        success: response
                    });
                },
                focus: function () {
                    return false;
                },
                select: function (event, ui) {
                    var terms = split(this.value);
                    terms.pop();
                    terms.push(ui.item.value);
                    terms.push(" ");
                    this.value = terms.join(" ");
                    return false;
                }
            });
    }
}

annotorious.plugin.YaleIIIF.prototype.initPlugin = function(anno) {
  var self = this;
  anno.addHandler('onAnnotationCreated', function(annotation) {
    self._create(annotation);
  });

  anno.addHandler('onAnnotationUpdated', function(annotation) {
    self._update(annotation);
  });

  anno.addHandler('onAnnotationRemoved', function(annotation) {
    self._delete(annotation);
  });

  anno.addHandler("onEditorShown", function(annotation) {
      self.onEditorShown(annotation);
  })
  
  //self._loadAnnotations(anno);
}

annotorious.plugin.YaleIIIF.prototype.onInitAnnotator = function(annotator) {
  //var spinner = this._newLoadIndicator();
  //annotator.element.appendChild(spinner);
  //this._loadIndicators.push(spinner);

  annotator.popup.addField(function(annotation) {
      var name = 'new annotation';
      if (annotation.author !== undefined) {
          name = '<em class="annotation_attribution">' + annotation.author + '</em>'
      }
      return name;
  });

}

annotorious.plugin.YaleIIIF.prototype._newLoadIndicator = function() {
  var outerDIV = document.createElement('div');
  outerDIV.className = 'annotorious-es-plugin-load-outer';
  
  var innerDIV = document.createElement('div');
  innerDIV.className = 'annotorious-es-plugin-load-inner';
  
  outerDIV.appendChild(innerDIV);
  return outerDIV;
}

annotorious.plugin.YaleIIIF.prototype.removeLoadIndicators = function() {
    // Remove all load indicators
    if (typeof(this._loadIndicators) != 'undefined') {
        jQuery.each(this._loadIndicators, function (idx, spinner) {
            jQuery(spinner).remove();
        });
    }
}

/**
 * @private
 */
annotorious.plugin.YaleIIIF.prototype._showError = function(error) {
  // TODO proper error handling
  window.alert('ERROR');
  console.log(error);
}

/**
 * @private
 */
annotorious.plugin.YaleIIIF.prototype._loadAnnotations = function(anno) {
  // TODO need to restrict search to the URL of the annotated
  var self = this;
  var canvasHeight = this._CANVAS_HEIGHT;
  jQuery.ajax({
      dataType: 'json',
      headers: {
          Accept : "application/json",
          "Content-Type": "application/json; charset=utf-8"
      },
      url: this._STORE_URI + '/annotation?canvas=' + this._CANVAS_URI,
      xhrFields: {
          withCredentials: true
      },
      success: function (data) {
          try {
              jQuery.each(data, function (idx, hit) {

                  var iiif_on = hit['on'].split('#');
                  var selectors = iiif_on[1].substring(5).split(',');

                  var shapes = [{
                      "type": 'rect',
                      "geometry": {
                          "x" : parseInt(selectors[0]),
                          "y" : parseInt(canvasHeight - selectors[1] - selectors[3]),
                          "width": parseInt(selectors[2]),
                          "height": parseInt(selectors[3])
                      }
                  }];
                  var annotation = {
                      "id": hit['@id'],
                      "text": hit['resource']['chars'],
                      "shapes": shapes,
                      "editable": hit['toolSupport']['editable'],
                      "author" : hit['annotatedBy']['name'],
                      "src": "map://openlayers/something"   // Should logically be hit['src']
                  };
                  console.log(shapes);
                  console.log(annotation);
                  if (jQuery.inArray(annotation.id, self._annotations) < 0) {
                      self._annotations.push(annotation.id);
                      if (!annotation.shape && annotation.shapes[0].geometry)
                          anno.addAnnotation(annotation);
                  }
              });
          } catch (e) {
              self._showError(e);
          }

          // Remove all load indicators
          jQuery.each(self._loadIndicators, function (idx, spinner) {
              jQuery(spinner).remove();
          });
      },
      error : function (jq, status, error) {
          self._showError(error);
      }
   });
}

/**
 * @private
 */
annotorious.plugin.YaleIIIF.prototype._create = function (annotation) {
    var self = this;

    // TODO : better solution for Openlayers geometry
    var x = annotation['shapes'][0]['geometry']['x'];
    var w = annotation['shapes'][0]['geometry']['width'];
    var h = annotation['shapes'][0]['geometry']['height'];
    var y = this._CANVAS_HEIGHT - annotation['shapes'][0]['geometry']['y'] - h;
    var selector = [x,y,w,h].join();
    var iiif_on = this._CANVAS_URI + "#xywh=" + selector;

    var newanno = {
      toolSupport: {
          canvas: this._CANVAS_URI,
          canvasLabel: this._CANVAS_LABEL,
          manifest: this._MANIFEST_URI,
          manifestLabel: this._MANIFEST_LABEL,
          projectId: this._PROJECT_ID
      }
    };
    newanno['@type'] = 'oa:Annotation';
    newanno['on'] = iiif_on;
    newanno['motivation'] = 'oa:Describing';
    newanno['resource'] = {};
    newanno['resource']['type'] = 'cnt:ContentAsText';
    newanno['resource']['chars'] = annotation['text'];
    newanno['resource']['lang'] = 'en';
    newanno['resource']['format'] = 'text/plain';

    var annotation_lists = this._IMAGE_ANNOTATION_LISTS;
    jQuery.ajax({
        type: 'POST',
        dataType: 'json',
        accepts: "application/json",
        xhrFields: {
            withCredentials: true
        },
        url: this._STORE_URI + 'annotation.json',
        data: {'annotation': newanno},
        success: function (response) {
            // TODO error handling if response status != 201 (CREATED)
            var id = response['_id'];
            annotation.id = id;
            annotation_list_uri = response['annotation_list_uri'];
            console.log(annotation_list_uri);
            var list_is_present = jQuery.inArray(annotation_list_uri, annotation_lists);
            if (list_is_present < 0) {
                annotation_lists.push(annotation_list_uri);
            }
        },
        error : function (jq, status, error) {
            self._showError(error);
        }
    });
}

/**
 * @private
 */
annotorious.plugin.YaleIIIF.prototype._update = function (annotation) {
    var self = this;

    // TODO : better solution for Openlayers geometry
    var x = annotation['shapes'][0]['geometry']['x'];
    var w = annotation['shapes'][0]['geometry']['width'];
    var h = annotation['shapes'][0]['geometry']['height'];
    var y = this._CANVAS_HEIGHT - annotation['shapes'][0]['geometry']['y'] - h;
    var selector = [x,y,w,h].join();
    var iiif_on = this._CANVAS_URI + "#xywh=" + selector;

    var newanno = {
        toolSupport: {
            canvas: this._CANVAS_URI,
            canvasLabel: this._CANVAS_LABEL,
            manifest: this._MANIFEST_URI,
            manifestLabel: this._MANIFEST_LABEL,
            projectId: this._PROJECT_ID
        }
    };
    newanno['@id'] = annotation.id;
    newanno['@type'] = 'oa:Annotation';
    newanno['on'] = iiif_on;
    newanno['motivation'] = 'oa:Describing';
    newanno['resource'] = {};
    newanno['resource']['type'] = 'cnt:ContentAsText';
    newanno['resource']['chars'] = annotation['text'];
    newanno['resource']['lang'] = 'en';
    newanno['resource']['format'] = 'text/plain';

    jQuery.ajax({
        url: annotation.id,
        type: 'PUT',
        dataType: 'json',
        accepts: "application/json",
        xhrFields: {
            withCredentials: true
        },
        headers: {
            Accept : "application/json"
        },
        data: {'annotation': newanno},
        error : function (jq, status, error) {
            self._showError(error);
        }
    });
}

/**
 * @private
 */
annotorious.plugin.YaleIIIF.prototype._delete = function(annotation) {
  jQuery.ajax({
    url: annotation.id,
    type: 'DELETE',
    headers: {
      Accept : "application/json"
    },
    xhrFields: {
      withCredentials: true
    },
    success: function (response) {
        alert("Annotation deleted");
    },
    error : function (jq, status, error) {
        self._showError(error);
    }
  });
}

