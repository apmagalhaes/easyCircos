# A heatmap configuration
# innerRadius: 200
# outerRadius: 250
# min: 'smart'
# max: 'smart'
# colorPalette: 'YlGnBu'
# colorPaletteSize: 9
do (angular) ->
  angular.module('trackManager').controller 'trackCtrl', ($scope, circosJS, tracks, helpStore, $modal, trackStore, defaults, dataParser) ->
    $scope.currentForm = 'layout'

    $scope.$on 'current-track-update', ->
      # clear input type "file" to force triggering data parsing if file is identical
      document.getElementsByClassName('import-file').value = null

      tracks.getCurrentTrack (currentTrack) ->
        $scope.currentForm = currentTrack.type
        $scope.currentTrack = currentTrack

    $scope.updateTrackName = () ->
      tracks.updateName($scope.currentTrack.id, $scope.currentTrack.name)

    $scope.data = dataParser
    $scope.parseData = ($fileContent) ->
      dataParser.parse($fileContent, (parsedData) ->
        $scope.currentTrack.data = parsedData
        $scope.render()
      )

    $scope.render = ->
      conf = angular.copy($scope.currentTrack.conf)
      if $scope.currentTrack.type == 'heatmap'
        circosJS.easyCircos.heatmap(
          $scope.currentTrack.id,
          conf,
          $scope.currentTrack.data
        )
      else if $scope.currentTrack.type == 'chords'
        circosJS.easyCircos.chords(
          $scope.currentTrack.id,
          conf,
          $scope.currentTrack.data
        )
      circosJS.easyCircos.render()

    # TODO: move trackType dependency in confManager
    $scope.updatePalette = (paletteName, range, palette) ->
      $scope.currentTrack.conf.colorPalette = paletteName #**************************
      $scope.currentTrack.conf.colorPaletteSize = range #**************************
      $scope.render()

    $scope.showHeatmapDataModal = ->
      modalInstance = $modal.open
        templateUrl: 'modules/help/heatmapData.modal.html'
        controller: 'ModalCancelCtrl'
        backdrop: true

    $scope.help = helpStore

    # dealing with track library
    $scope.tracks = []
    trackStore.getStore (tracks) ->
      $scope.tracks = tracks
      $scope.selected =
        track: null

    $scope.selectTrack = ->
      trackStore.getTrack $scope.selected.track._id, (track) ->
        $scope.currentTrack.conf = defaults(track.conf, $scope.currentTrack.conf)
        $scope.currentTrack.data = track.data
        $scope.render()
