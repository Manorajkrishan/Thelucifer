"""Unit tests for DatasetManager."""
import json
import tempfile
from pathlib import Path

import pytest

from services.dataset_manager import DatasetManager


@pytest.fixture
def tmp_datasets_dir(tmp_path):
    return tmp_path / "datasets"


@pytest.fixture
def manager(tmp_datasets_dir):
    return DatasetManager(datasets_dir=str(tmp_datasets_dir))


def test_list_available_datasets(manager):
    avail = manager.list_available_datasets()
    assert "cicids2017" in avail
    assert "unsw-nb15" in avail
    assert "nsl-kdd" in avail
    assert "ember" in avail
    assert avail["cicids2017"]["name"] == "CICIDS2017"


def test_download_dataset_without_url_returns_instructions(manager):
    out = manager.download_dataset("cicids2017")
    assert out["success"] is False
    assert "Manual download" in out["message"]
    assert "instructions" in out


def test_add_custom_dataset(manager, tmp_path):
    f = tmp_path / "sample.csv"
    f.write_text("a,b,c\n1,2,3\n")
    meta = {"name": "My Dataset", "description": "Test", "format": "csv"}
    out = manager.add_custom_dataset(str(f), "my_dataset", meta)
    assert out["success"] is True
    assert out["dataset_id"] == "my_dataset"
    assert (manager.datasets_dir / "my_dataset" / "sample.csv").exists()
    meta_path = manager.datasets_dir / "my_dataset" / "metadata.json"
    assert meta_path.exists()
    assert json.loads(meta_path.read_text())["name"] == "My Dataset"


def test_list_downloaded_datasets_includes_custom(manager, tmp_path):
    f = tmp_path / "x.csv"
    f.write_text("x\n1\n")
    manager.add_custom_dataset(str(f), "custom_x", {"name": "X", "format": "csv"})
    down = manager.list_downloaded_datasets()
    ids = [d["id"] for d in down]
    assert "custom_x" in ids or any("custom_x" in i for i in ids)
