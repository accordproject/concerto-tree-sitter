package tree_sitter_concerto_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_concerto "github.com/accordproject/concerto-tree-sitter/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_concerto.Language())
	if language == nil {
		t.Errorf("Error loading Concerto grammar")
	}
}
