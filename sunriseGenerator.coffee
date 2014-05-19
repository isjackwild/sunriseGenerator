cv = document.getElementById 'sunriseGenerator'
cv.width = window.innerWidth
cv.height = window.innerHeight
ctx = cv.getContext('2d')


skyCols = ["rgb(241, 250, 255)", "rgb(9, 91, 184)", "rgb(179, 44, 44)", "rgb(69, 65, 104)", "rgb(40, 171, 197)", "rgb(128, 172, 219)", "rgb(0, 80, 146)", "rgb(47, 44, 67)", "rgb(42, 42, 97)", "rgb(131, 63, 24)", "rgb(58, 182, 196)", "rgb(39, 135, 254)"]
horizonCols = ["rgb(242, 92, 76)", "rgb(253, 141, 24)", "rgb(252, 254, 112)", "rgb(253, 64, 103)", "rgb(252, 230, 149)", "rgb(255, 224, 55)", "rgb(251, 210, 92)", "rgb(250, 191, 70)", "rgb(179, 69, 1)", "rgb(248, 248, 164)", "rgb(255, 56, 105)", "rgb(255, 128, 22)"]


class sunriseEngine
	@_borderMinThickness
	@_borderFeather
	@_borderMaxThickness
	@_borderBlur

	@_gradScale
	@_streakyness
	@_noiseLoops

	@_skyCol
	@_horizonCol

	@_throttle = 5000

	constructor: (ctx, w, h) ->
		@_ctx = ctx
		@_w = w
		@_h = h

	init: ()=>
		@randomise()
		@render()

	randomNumber: (min, max, integer = true) =>
		if integer is true
			return Math.floor Math.random()*(min-max+1) + min
		else if integer is false
			return Math.random()*(min-max) + min


	randomise: () =>
		console.log "randomise"

		@_borderMinThickness = @randomNumber 5,20
		@_borderFeather = @randomNumber 10,20
		@_borderMaxThickness = @_borderMinThickness + @_borderFeather
		@_borderBlur = @randomNumber 5,12
		
		@_gradScale = @randomNumber 0, 0.5, false
		@_streakyness = @randomNumber 2,8
		@_noiseLoops = @randomNumber 4,10

		@_skyCol = skyCols[Math.ceil(Math.random()*skyCols.length)-1]
		@_horizonCol = horizonCols[Math.ceil(Math.random()*horizonCols.length)-1]


	makeGradient: () =>
		console.log "make grad"

		colourStep = 0
		tempImage = @_ctx.createImageData @_w, @_h

		i = 0
		for pixel in tempImage.data
			if i%4 != 3
				tempImage.data[i]=10
			else
				tempImage.data[i]=255
			i++
		

		@_ctx.putImageData tempImage, 0, 0


	makeSun: () =>
		console.log "make sun"


	makeBorder: () =>
		console.log "make border"


	render: () =>
		@makeGradient()
		@makeBorder()
		@makeSun()

		# that = @
		# setTimeout ->
		# 	window.requestAnimationFrame that.render
		# ,@_throttle


$(window).load =>
	coverArtworkEngine = new sunriseEngine ctx, cv.width, cv.height
	coverArtworkEngine.init();