/*
 Copyright (C) 2010-2017 Kristian Duske
 
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
 along with TrenchBroom. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef TrenchBroom_MergeNodesIntoWorldVisitor
#define TrenchBroom_MergeNodesIntoWorldVisitor

#include "Model/ModelTypes.h"
#include "Model/NodeVisitor.h"

namespace TrenchBroom {
    namespace Model {
        class MergeNodesIntoWorldVisitor : public NodeVisitor {
        private:
            World* m_world;
            Node* m_parent;
            
            ParentChildrenMap m_result;
            mutable NodeList m_nodesToDetach;
            mutable NodeList m_nodesToDelete;
        public:
            MergeNodesIntoWorldVisitor(World* world, Node* parent);
            
            const ParentChildrenMap& result() const;
        private:
            void doVisit(World* world) override;
            void doVisit(Layer* layer) override;
            void doVisit(Group* group) override;
            void doVisit(Entity* entity) override;
            void doVisit(Brush* brush) override;
            
            void addNode(Node* node);
            void deleteNode(Node* node);
            void detachNode(Node* node);
            
            void deleteNodes() const;
            void detachNodes() const;
        };
    }
}

#endif /* defined(TrenchBroom_MergeNodesIntoWorldVisitor) */
