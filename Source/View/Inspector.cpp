/*
 Copyright (C) 2010-2012 Kristian Duske
 
 This file is part of TrenchBroom.
 
 TrenchBroom is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 TrenchBroom is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with TrenchBroom.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "Inspector.h"

#include <wx/sizer.h>

#include "View/ViewInspector.h"

namespace TrenchBroom {
    namespace View {
        wxNotebookPage* Inspector::CreateMapInspector() {
            return new wxPanel(m_notebook);
        }
        
        wxNotebookPage* Inspector::CreateEntityInspector() {
            return new wxPanel(m_notebook);
        }
        
        wxNotebookPage* Inspector::CreateBrushInspector() {
            return new wxPanel(m_notebook);
        }
        
        wxNotebookPage* Inspector::CreateFaceInspector() {
            return new wxPanel(m_notebook);
        }
        
        wxNotebookPage* Inspector::CreateViewInspector() {
            return new ViewInspector(m_notebook);
        }
        
        Inspector::Inspector(wxWindow* parent) : wxPanel(parent) {
            m_notebook = new wxNotebook(this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxNB_TOP | wxCLIP_CHILDREN);
            m_notebook->AddPage(CreateMapInspector(), wxT("Map"));
            m_notebook->AddPage(CreateEntityInspector(), wxT("Entity"));
            m_notebook->AddPage(CreateBrushInspector(), wxT("Brush"));
            m_notebook->AddPage(CreateFaceInspector(), wxT("Face"));
            m_notebook->AddPage(CreateViewInspector(), wxT("View"));
            
            wxSizer* notebookSizer = new wxBoxSizer(wxVERTICAL);
            notebookSizer->Add(m_notebook, 1, wxEXPAND);
            SetSizer(notebookSizer);
        }
    }
}