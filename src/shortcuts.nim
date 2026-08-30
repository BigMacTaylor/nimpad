# ========================================================================================
#
#                                   Nimpad
#                                  Shortcuts
#
# ========================================================================================

const shortcutsXml = """
<?xml version="1.0" encoding="UTF-8"?>
<interface>
  <requires lib="gtk" version="3.20"/>
  <object class="GtkApplicationWindow" id="shortcuts_window">
    <property name="title">Keyboard Shortcuts</property>
    <property name="default-width">550</property>
    <property name="default-height">420</property>

    <child type="titlebar">
      <object class="GtkHeaderBar" id="header_bar">
        <property name="visible">True</property>
        <property name="title" translatable="yes">Shortcuts</property>
        <property name="show-close-button">True</property>
      </object>
    </child>

    <child>
      <object class="GtkScrolledWindow" id="scrolled_window">
        <property name="hscrollbar-policy">never</property>
        <property name="vscrollbar-policy">automatic</property>
        <child>
          <object class="GtkBox">
            <property name="orientation">vertical</property>
            <property name="spacing">18</property>
            <property name="margin-top">20</property>
            <property name="margin-bottom">20</property>
            <property name="margin-start">20</property>
            <property name="margin-end">20</property>

            <!-- ================================================================= -->
            <!-- SECTION: Documents -->
            <!-- ================================================================= -->
            <child>
              <object class="GtkBox">
                <property name="orientation">vertical</property>
                <property name="spacing">6</property>

                <child>
                  <object class="GtkLabel">
                    <property name="label">Documents</property>
                    <property name="xalign">0</property>
                    <attributes>
                      <attribute name="weight" value="bold"/>
                    </attributes>
                    <style>
                      <class name="heading"/>
                    </style>
                  </object>
                </child>

                <child>
                  <object class="GtkListBox">
                    <property name="selection-mode">none</property>
                    <style>
                      <class name="boxed-list"/>
                    </style>

                    <!-- Save -->
                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Save current file</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;s</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Save file as...</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;&lt;Shift&gt;s</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                  </object>
                </child>
              </object>
            </child>

            <!-- ================================================================= -->
            <!-- SECTION: Copy & Paste -->
            <!-- ================================================================= -->
            <child>
              <object class="GtkBox">
                <property name="orientation">vertical</property>
                <property name="spacing">6</property>

                <child>
                  <object class="GtkLabel">
                    <property name="label">Copy &amp; Paste</property>
                    <property name="xalign">0</property>
                    <attributes>
                      <attribute name="weight" value="bold"/>
                    </attributes>
                    <style>
                      <class name="heading"/>
                    </style>
                  </object>
                </child>

                <child>
                  <object class="GtkListBox">
                    <property name="selection-mode">none</property>
                    <style>
                      <class name="boxed-list"/>
                    </style>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Copy selected text</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;c</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Cut selected text</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;x</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Paste text from clipboard</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;v</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Duplicate selected text</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;d</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                  </object>
                </child>
              </object>
            </child>

            <!-- ================================================================= -->
            <!-- SECTION: Undo & Redo -->
            <!-- ================================================================= -->
            <child>
              <object class="GtkBox">
                <property name="orientation">vertical</property>
                <property name="spacing">6</property>

                <child>
                  <object class="GtkLabel">
                    <property name="label">Undo &amp; Redo</property>
                    <property name="xalign">0</property>
                    <attributes>
                      <attribute name="weight" value="bold"/>
                    </attributes>
                    <style>
                      <class name="heading"/>
                    </style>
                  </object>
                </child>

                <child>
                  <object class="GtkListBox">
                    <property name="selection-mode">none</property>
                    <style>
                      <class name="boxed-list"/>
                    </style>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Undo last action</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;z</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Redo action</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;&lt;Shift&gt;z</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                  </object>
                </child>
              </object>
            </child>

            <!-- ================================================================= -->
            <!-- SECTION: Find & Replace -->
            <!-- ================================================================= -->
            <child>
              <object class="GtkBox">
                <property name="orientation">vertical</property>
                <property name="spacing">6</property>

                <child>
                  <object class="GtkLabel">
                    <property name="label">Find &amp; Replace</property>
                    <property name="xalign">0</property>
                    <attributes>
                      <attribute name="weight" value="bold"/>
                    </attributes>
                    <style>
                      <class name="heading"/>
                    </style>
                  </object>
                </child>

                <child>
                  <object class="GtkListBox">
                    <property name="selection-mode">none</property>
                    <style>
                      <class name="boxed-list"/>
                    </style>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Find text</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;f</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Grab next match</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;g</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Grab previous match</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;&lt;Shift&gt;g</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Replace text</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;r</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                  </object>
                </child>
              </object>
            </child>

            <!-- ================================================================= -->
            <!-- SECTION: Navigation -->
            <!-- ================================================================= -->
            <child>
              <object class="GtkBox">
                <property name="orientation">vertical</property>
                <property name="spacing">6</property>

                <child>
                  <object class="GtkLabel">
                    <property name="label">Navigation</property>
                    <property name="xalign">0</property>
                    <attributes>
                      <attribute name="weight" value="bold"/>
                    </attributes>
                    <style>
                      <class name="heading"/>
                    </style>
                  </object>
                </child>

                <child>
                  <object class="GtkListBox">
                    <property name="selection-mode">none</property>
                    <style>
                      <class name="boxed-list"/>
                    </style>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Move to word left</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;Left</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Move to word right</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;Right</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Jump to line</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;j</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                  </object>
                </child>
              </object>
            </child>

            <!-- ================================================================= -->
            <!-- SECTION: Select Text -->
            <!-- ================================================================= -->
            <child>
              <object class="GtkBox">
                <property name="orientation">vertical</property>
                <property name="spacing">6</property>

                <child>
                  <object class="GtkLabel">
                    <property name="label">Select Text</property>
                    <property name="xalign">0</property>
                    <attributes>
                      <attribute name="weight" value="bold"/>
                    </attributes>
                    <style>
                      <class name="heading"/>
                    </style>
                  </object>
                </child>

                <child>
                  <object class="GtkListBox">
                    <property name="selection-mode">none</property>
                    <style>
                      <class name="boxed-list"/>
                    </style>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Select all</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;a</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Unselect all</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;&lt;Shift&gt;a</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Select word</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;w</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Select word left</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;&lt;Shift&gt;Left</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Select word right</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;&lt;Shift&gt;Right</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Select line</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;l</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Unselect line</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;&lt;Shift&gt;l</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Select line up</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;&lt;Shift&gt;Up</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Select line down</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;&lt;Shift&gt;Down</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                  </object>
                </child>
              </object>
            </child>

            <!-- ================================================================= -->
            <!-- SECTION: Move Text -->
            <!-- ================================================================= -->
            <child>
              <object class="GtkBox">
                <property name="orientation">vertical</property>
                <property name="spacing">6</property>

                <child>
                  <object class="GtkLabel">
                    <property name="label">Move Text</property>
                    <property name="xalign">0</property>
                    <attributes>
                      <attribute name="weight" value="bold"/>
                    </attributes>
                    <style>
                      <class name="heading"/>
                    </style>
                  </object>
                </child>

                <child>
                  <object class="GtkListBox">
                    <property name="selection-mode">none</property>
                    <style>
                      <class name="boxed-list"/>
                    </style>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Move selected text up</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Alt&gt;Up</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Move selected text down</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Alt&gt;Down</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                  </object>
                </child>
              </object>
            </child>

            <!-- ================================================================= -->
            <!-- SECTION: General -->
            <!-- ================================================================= -->
            <child>
              <object class="GtkBox">
                <property name="orientation">vertical</property>
                <property name="spacing">6</property>

                <child>
                  <object class="GtkLabel">
                    <property name="label">General</property>
                    <property name="xalign">0</property>
                    <attributes>
                      <attribute name="weight" value="bold"/>
                    </attributes>
                    <style>
                      <class name="heading"/>
                    </style>
                  </object>
                </child>

                <child>
                  <object class="GtkListBox">
                    <property name="selection-mode">none</property>
                    <style>
                      <class name="boxed-list"/>
                    </style>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Preferences</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;comma</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Show keyboard shortcuts</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;question</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                    <child>
                      <object class="GtkListBoxRow">
                        <child>
                          <object class="GtkBox">
                            <property name="orientation">horizontal</property>
                            <property name="spacing">12</property>
                            <child>
                              <object class="GtkLabel">
                                <property name="label">Quit application</property>
                                <property name="hexpand">TRUE</property>
                                <property name="xalign">0</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkShortcutLabel">
                                <property name="accelerator">&lt;Control&gt;q</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>

                  </object>
                </child>
              </object>
            </child>

          </object>
        </child>

      </object>
    </child>

  </object>
</interface>
"""

proc onShortcutsKeyPress(window: ApplicationWindow; event: gdk.EventKey, scrollBox: ScrolledWindow): bool =
  let key = event.getKeyval

  case key
  of KEY_Escape:
    window.close()
  of KEY_Up:
    # Scroll up
    let vadj = getVadjustment(scrollBox)
    let current = vadj.getValue()
    let step = vadj.getStepIncrement()
    let lower = vadj.getLower()
    vadj.setValue(max(current - step, lower))
  of KEY_Down:
    # Scroll down
    let vadj = getVadjustment(scrollBox)
    let current = vadj.getValue()
    let step = vadj.getStepIncrement()
    let lower = vadj.getLower()
    vadj.setValue(max(current + step, lower))
  else:
    discard

  return true # Event handled

proc shortcuts(app: Application) =
  let builder = newBuilder()
  discard builder.addFromString(cstring(shortcutsXml), uint64(-1))

  let win = builder.getApplicationWindow("shortcuts_window")
  win.setModal(true)
  win.setTransientFor(p.window)
  win.setApplication(app)

  let scrolled = cast[ScrolledWindow](builder.getObject("scrolled_window"))
  win.connect("key-press-event", onShortcutsKeyPress, scrolled)

  win.showAll()
