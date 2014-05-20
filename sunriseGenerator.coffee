cv = document.getElementById 'sunriseGenerator'
cv.width = screen.width
cv.height = screen.height
ctx = cv.getContext('2d')


topFill = document.getElementById 'topFill'
bottomFill = document.getElementById 'bottomFill'


#I picked colours from sunrise photos
skyCols = [{r:241, g:250, b:255}, {r:9, g:91, b:184}, {r:179, g:44, b:44}, {r:69, g:65, b:104}, {r:40, g:171, b:197}, {r:128, g:172, b:219}, {r:0, g:80, b:146}, {r:47, g:44, b:67}, {r:42, g:42, b:97}, {r:131, g:63, b:24}, {r:58, g:182, b:196}, {r:39, g:135, b:254}]
horizonCols = [{r:242, g:92, b:76}, {r:253, g:141, b:24}, {r:252, g:254, b:112}, {r:253, g:64, b:103}, {r:252, g:230, b:149}, {r:255, g:224, b:55}, {r:251, g:210, b:92}, {r:250, g:191, b:70}, {r:179, g:69, b:1}, {r:248, g:248, b:164}, {r:255, g:56, b:105}, {r:255, g:128, b:22}]


#The sunrise engine
class sunriseEngine
	@_borderMinThickness
	@_borderFeather
	@_borderMaxThickness
	@_borderBlur

	@_gradScale
	@_streakyness
	@_minusOffset
	@_plusOffset

	@_skyCol
	@_horizonCol
	@_finalCol

	@_radius
	@_sunPosOffset

	@_noiseVariation

	@_throttle = 1000

	constructor: (ctx, w, h) ->
		@_ctx = ctx
		@_w = w
		@_h = h


	init: ()=>
		@randomise()
		@render()


	randomNumber: (min, max, int = true) =>
		if int is true
			return Math.ceil(Math.random()*(max-min) + min)
		else
			return Math.random()*(max-min) + min


	#So useful...
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


	#Linear interpolation between colours
	lerpColour: (control, from, to) =>
		resultR = from.r + (to.r - from.r) * control
		resultG = from.g + (to.g - from.g) * control
		resultB = from.b + (to.b - from.b) * control

		resultR = Math.ceil resultR
		resultG = Math.ceil resultG
		resultB = Math.ceil resultB

		result = {r:resultR, g:resultG, b:resultB}
		return result


	#I randomise the inputs each time, after a lot of experimenting about the ranges to set to create pleasant outcomes.
	randomise: () =>
		@_borderMinThickness = @randomNumber 5,20
		@_borderFeather = @randomNumber 10,20
		@_borderMaxThickness = @_borderMinThickness + @_borderFeather
		@_borderBlur = @randomNumber 5,12
		
		@_minusOffset = @randomNumber 1, 3
		@_plusOffset = @randomNumber 2, 5

		@_gradScale = @randomNumber 0, 0.33, false
		@_streakyness = @randomNumber 4,12
		@_noiseVariation = @randomNumber 3, 8

		@_skyCol = skyCols[Math.ceil(Math.random()*skyCols.length)-1]
		@_horizonCol = horizonCols[Math.ceil(Math.random()*horizonCols.length)-1]

		@_radius = @randomNumber (@_h/6), (@_h/6)*1.33
		@_sunPosOffset = @randomNumber 0, @_h/4


	makeGradient: () =>
		colourStep = 0

		#The colourJump controls the lerpControl, which controls the stripeyness and progression of the gradient
		for i in [0...@_h]
			colourJump = @randomNumber(-(@_streakyness+@_minusOffset), @_streakyness+@_plusOffset)
			
			colourStep += colourJump
			lerpControl = @convertToRange colourStep, [0,@_h], [-@_gradScale, 1+@_gradScale]

			if lerpControl < 0
				tempCol = @_skyCol
			else if lerpControl > 1
				tempCol = @_horizonCol
			else
				tempCol = @lerpColour lerpControl, @_skyCol, @_horizonCol

			#Draw the lines which make up the gradient row by row
			tempColRGB = "rgb(" + tempCol.r + "," + tempCol.g + "," + tempCol.b + ")"
			@_ctx.strokeStyle = tempColRGB
			@_ctx.beginPath()
			@_ctx.moveTo(0,i)
			@_ctx.lineTo(@_w,i)
			@_ctx.stroke()

			if i is @_h-1
				@_finalCol = tempCol
		
			
	makeSun: () =>
		#every sunrise needs a sun!
		@_ctx.beginPath()
		@_ctx.arc(@_w/2, (@_h/2)+@_sunPosOffset, @_radius, 0, 2*Math.PI)
		@_ctx.fillStyle = "#FFFFFF"
		@_ctx.fill()


	addNoise: () =>
		#take the gradient and get the image data.
		tempImage = @_ctx.getImageData 0, 0, @_w, @_h
		brightness = 0

		for i in [0...tempImage.data.length]
			if i%4 != 3
				brightness += tempImage.data[i]
			else
				brightness /= 3
				tempImage.data[i]=255

				#Add a random amount of noise, and then reduce this in darker areas. Fully white = full amount of noise, fully back = no noise.
				noise = @randomNumber -@_noiseVariation, @_noiseVariation
				noise *= @convertToRange brightness, [0 , 255], [0.2, 1]
				tempImage.data[i-1] += noise

				noise = @randomNumber -@_noiseVariation, @_noiseVariation
				noise *= @convertToRange brightness, [0 , 255], [0.2, 1]
				tempImage.data[i-2] += noise

				noise = @randomNumber -@_noiseVariation, @_noiseVariation
				noise *= @convertToRange brightness, [0 , 255], [0.2, 1]
				tempImage.data[i-1] += noise

				brightness = 0
			i++

		#write the noisey image data back into the canavs
		@_ctx.putImageData tempImage, 0, 0


	render: () =>
		@_ctx.clearRect 0,0,@_w,@_h
		@randomise()
		@makeGradient()
		@addNoise()
		@makeSun()
		@fillInSides()

		#a new sunrise is rendered every second.
		that = @
		setTimeout ->
			window.requestAnimationFrame that.render
		, 1000


	#Click to save
	saveSunrise: () =>
		cv.toBlob (blob) ->
			saveAs blob, 'sunrise.png'

	#Fill the divs at the top and bottom with the start and end colour so it doesn't look ugly when you resize the browser window.
	fillInSides: () =>
		topFill.style.background = "rgb(" + @_skyCol.r + "," + @_skyCol.g + "," + @_skyCol.b + ")"
		bottomFill.style.background = "rgb(" + @_finalCol.r + "," + @_finalCol.g + "," + @_finalCol.b + ")"



$(window).load =>
	sunEngine = new sunriseEngine ctx, cv.width, cv.height
	sunEngine.init()

	document.getElementById('sunriseGenerator').onclick = ()=>
		console.log 'click'
		sunEngine.saveSunrise()


$('#closeAbout').click =>
	console.log "close"
	$('#about').toggleClass 'closed'

	setTimeout ->
		$('#about').bind "click", ->
			$('#about').toggleClass 'closed'
			$('#about').unbind "click"
	,0
