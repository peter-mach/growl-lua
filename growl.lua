--
-- Code by Piotr Machowski <piotr@machowski.co>
--
local Growl = {}
Growl.__n = 'GrowlNotifications'
Growl.set = {}
Growl.isAnimating = false

--global config
Growl.SHOW_TIME = 5000
Growl.FONT_SIZE = 8
Growl.NOTIFICATION_WIDTH = display.contentWidth*.25

--private functions
function Growl:_removeNotification( _n )
	for i,v in ipairs(self.set) do
		if _n == v then table.remove( self.set, i ) end
	end
end

function Growl:_moveNotifications(  )
	if self.isAnimating then -- speed move
		transition.cancel( Growl.__n )
		for i,v in ipairs(self.set) do
			v.x, v.y = v.nx, v.ny
		end
	end
	self.isAnimating=true
	--remove those not in the viewport
	for i=#self.set,1 do
		if self.set[i].y > display.contentHeight then self.set[i]:removeSelf() end
	end

	--animate
	self.set[1].tween = transition.to( self.set[1], {tag=Growl.__n, x=self.set[1].nx, time=200, easing=easing.outExpo,
		onComplete=function(  )
			Growl.isAnimating=false
		end } )

	if #self.set>1 then
		for i=2,#self.set do
			self.set[i].ny = self.set[i-1].ny+self.set[i-1].height+5
			self.set[i].tween = transition.to( self.set[i], {tag=Growl.__n, y=self.set[i].ny, time=150, easing=easing.inExpo } )
		end
	end
end

--Public methods
function Growl:removeAllNotifications()
	for i=#self.set,1 do
		self.set[i]:removeSelf()
	end
	self.isAnimating=false
end

function Growl.new( _msg, _type, _width, _fontSize )
	local w,h = _width or Growl.NOTIFICATION_WIDTH
	local fontSize = _fontSize or Growl.FONT_SIZE
	local m = display.newGroup( )

	local function init(  )
		m.txt = display.newText( {parent=m, text=_msg, x=0,y=0,width=w-10, fontSize=fontSize, align='left'})
		h = m.txt.height+10

		m.bg = display.newRoundedRect(m, 0, 0, w, h, 4 )
		if _type == 'error' then
			m.bg:setFillColor( 244/255, 122/255, 102/255, .9 )
		elseif _type == 'info' then
			m.bg:setFillColor( 111/255, 169/255, 228/255, .9 )
		else
			m.bg:setFillColor( 67/255, 172/255, 102/255, .9 )
		end
		m.bg.strokeWidth=1
		m.bg:setStrokeColor( 1,1,1,.2 )

		m.txt:toFront( )

		--config
		m.alpha=.8
		m.anchorChildren=true
		m.anchorX, m.anchorY = 1,0
		m.x, m.y = display.contentWidth+10+w, 10
		m.nx, m.ny= display.contentWidth-10, m.y
		table.insert( Growl.set, 1, m )
	end

	local function initRemove( )
		function m:timer (  )
			self:removeSelf()
		end
		m.removeTimer = timer.performWithDelay( Growl.SHOW_TIME, m)
	end

	m._removeSelf = m.removeSelf
	function m:removeSelf(  )
		if self.removeTimer then timer.cancel( self.removeTimer ) end
		self.removeTimer=nil
		if self.tween then transition.cancel( self.tween ) end
		self.tween=nil
		Growl:_removeNotification(self)
		self:_removeSelf()
	end


	init()
	initRemove()
	Growl:_moveNotifications()
	return m
end

return Growl
