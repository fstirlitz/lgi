--[[-- Assorted tests. --]]--

require 'lgi'
local GLib = require 'lgi.GLib'
local Gio = require 'lgi.Gio'
local Gtk = lgi.Gtk

local tests = { 'asyncread', 'gtkhello' }

function tests.asyncread()
   local stream
   local main = GLib.MainLoop.new(nil, false)
   local file = Gio.file_new_for_path('test.lua')
   file:read_async(GLib.PRIORITY_DEFAULT, nil,
		   function(o, asr)
		      print(string.format(
			       'read_closure(%s, %s)', tostring(o),
			       tostring(asr)))
		      stream = file:read_finish(asr)
		      main:quit()
		   end)
   main:run()
   assert(stream)
end

function tests.gtkhello()
   -- Based on test from LuiGI code.  Thanks Adrian!
   Gtk.init(0, nil)
   local window = Gtk.Window {
      title = 'window',
      default_width = 400,
      default_height = 300,
      on_delete_event = Gtk.main_quit
   }
   local status_bar = Gtk.Statusbar { has_resize_grip = true }
   local toolbar = Gtk.Toolbar()
   local vbox = Gtk.VBox()
   local ctx = status_bar:get_context_id('default')
   status_bar:push(ctx, 'This is statusbar message.')
   toolbar:insert(Gtk.ToolButton {
		     stock_id = 'gtk-quit',
		     on_clicked = Gtk.main_quit
		  }, -1)
   toolbar:insert(Gtk.ToolButton {
		     stock_id = 'gtk-about',
		     on_clicked = function()
				     local dlg = Gtk.AboutDialog {
					program_name = 'LGI Demo',
					title = 'About...',
					license = 'MIT'
				     }
				     dlg:run()
				     dlg:hide()
				  end
		  }, -1)
   vbox:pack_start(toolbar, false, false, 0)
   vbox:pack_start(Gtk.Label { label = 'Contents' }, true, true, 0)
   vbox:pack_end(status_bar, false, false, 0)
   window:add(vbox)
   window:show_all()
   Gtk.main()
end

-- Runs specified test from tests table.
local function runtest(name)
   local func = tests[name]
   if type(func) ~= 'function' then
      print(string.format('ERRR: %s is not known test', name))
   else
      local ok, msg = pcall(tests[name])
      if ok then
	 print(string.format('PASS: %s', name))
      else
	 print(string.format('FAIL: %s: %s', name, tostring(msg)))
      end
   end
end

-- Run all tests from commandline, or all tests sequentially, if not
-- commandline is given.
for _, name in ipairs(#arg > 0 and arg or tests) do runtest(name) end
