cv = document.getElementById 'sunriseGenerator'
cv.width = screen.width
cv.height = screen.height

console.log screen.width, screen.height, "<<"

ctx = cv.getContext('2d')

skyCols = [{r:241, g:250, b:255}, {r:9, g:91, b:184}, {r:179, g:44, b:44}, {r:69, g:65, b:104}, {r:40, g:171, b:197}, {r:128, g:172, b:219}, {r:0, g:80, b:146}, {r:47, g:44, b:67}, {r:42, g:42, b:97}, {r:131, g:63, b:24}, {r:58, g:182, b:196}, {r:39, g:135, b:254}]
horizonCols = [{r:242, g:92, b:76}, {r:253, g:141, b:24}, {r:252, g:254, b:112}, {r:253, g:64, b:103}, {r:252, g:230, b:149}, {r:255, g:224, b:55}, {r:251, g:210, b:92}, {r:250, g:191, b:70}, {r:179, g:69, b:1}, {r:248, g:248, b:164}, {r:255, g:56, b:105}, {r:255, g:128, b:22}]

class sunriseEngine
	@_borderMinThickness
	@_borderFeather
	@_borderMaxThickness
	@_borderBlur

	@_gradScale
	@_streakyness
	@_minusOffset
	@_plusOffset
	@_noiseLoops

	@_skyCol
	@_horizonCol

	@_radius
	@_sunPosOffset

	@_noiseVariation

	@_throttle = 1000

	constructor: (ctx, w, h) ->
		@_ctx = ctx
		@_w = w
		@_h = h
		@_minusOffset = 0
		@_plusOffset = 2


	init: ()=>
		@randomise()
		@render()


	randomNumber: (min, max, int = true) =>
		if int is true
			return Math.ceil(Math.random()*(max-min) + min)
		else
			return Math.random()*(max-min) + min

	convertToRange: (value, srcRange, dstRange) =>
		if value < srcRange[0]
			return dstRange[0]
		else if value > srcRange[1]
			return dstRange[1]
		else
			srcMax = srcRange[1] - srcRange[0]
			dstMax = dstRange[1] - dstRange[0]
			adjValue = value  - srcRange[0]
			return (adjValue * dstMax / srcMax) + dstRange[0]

	lerpColour: (control, from, to) =>
		resultR = from.r + (to.r - from.r) * control
		resultG = from.g + (to.g - from.g) * control
		resultB = from.b + (to.b - from.b) * control

		resultR = Math.ceil resultR
		resultG = Math.ceil resultG
		resultB = Math.ceil resultB

		result = {r:resultR, g:resultG, b:resultB}
		return result


	randomise: () =>
		@_borderMinThickness = @randomNumber 5,20
		@_borderFeather = @randomNumber 10,20
		@_borderMaxThickness = @_borderMinThickness + @_borderFeather
		@_borderBlur = @randomNumber 5,12
		
		@_gradScale = @randomNumber 0, 0.5, false
		@_streakyness = @randomNumber 2,8
		@_noiseLoops = @randomNumber 4,10
		@_noiseVariation = @randomNumber 2, 7

		@_skyCol = skyCols[Math.ceil(Math.random()*skyCols.length)-1]
		@_horizonCol = horizonCols[Math.ceil(Math.random()*horizonCols.length)-1]

		@_radius = @randomNumber (@_h/6), (@_h/6)*1.33
		@_sunPosOffset = @randomNumber 0, @_h/4



	makeGradient: () =>
		colourStep = 0

		for i in [0...@_h]
			colourJump = @randomNumber(-(@_streakyness+@_minusOffset), @_streakyness+@_plusOffset)
			
			colourStep += colourJump
			lerpControl = @convertToRange colourStep, [0,@_h], [0-@_gradScale, 1+@_gradScale]

			if lerpControl < 0
				tempCol = @_skyCol
			else if lerpControl > 1
				tempCol = @_horizonCol
			else
				tempCol = @lerpColour lerpControl, @_skyCol, @_horizonCol


			tempColRGB = "rgb(" + tempCol.r + "," + tempCol.g + "," + tempCol.b + ")"
			@_ctx.strokeStyle = tempColRGB
			@_ctx.beginPath()
			@_ctx.moveTo(0,i)
			@_ctx.lineTo(@_w,i)
			@_ctx.stroke()
		
			
	makeSun: () =>
		@_ctx.beginPath()
		@_ctx.arc(@_w/2, (@_h/2)+@_sunPosOffset, @_radius, 0, 2*Math.PI)
		@_ctx.fillStyle = "#FFFFFF"
		@_ctx.fill()


	makeBorder: () =>
		console.log "make border"


	addNoise: () =>
		tempImage = @_ctx.getImageData 0, 0, @_w, @_h

		for i in [0...tempImage.data.length]
			if i%4 != 3
				noise = @randomNumber -@_noiseVariation, @_noiseVariation
				tempImage.data[i] += noise
			else
				tempImage.data[i]=255
			i++

		@_ctx.putImageData tempImage, 0, 0


	render: () =>
		@_ctx.clearRect 0,0,@_w,@_h
		@randomise()
		@makeGradient()
		@addNoise()
		@makeBorder()
		@makeSun()

		that = @
		setTimeout ->
			window.requestAnimationFrame that.render
		, 5000

	saveSunrise: () =>
		console.log 'save'
		dataURL = cv.toDataURL "image/png"
		saveWindow = window.open()
		saveWindow.document.write '<img src="'+dataURL+'"/>'


$(window).load =>
	coverArtworkEngine = new sunriseEngine ctx, cv.width, cv.height
	coverArtworkEngine.init()

	document.getElementById('sunriseGenerator').onclick = ()=>
		console.log 'click'
		coverArtworkEngine.saveSunrise()
