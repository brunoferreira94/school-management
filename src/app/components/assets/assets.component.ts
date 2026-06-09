import { Component, OnInit } from "@angular/core";
import { AssetService, AssetDto } from "../../services/asset.service";

@Component({
  selector: "app-assets",
  templateUrl: "./assets.component.html",
  standalone: true,
})
export class AssetsComponent implements OnInit {
  assets: AssetDto[] = [];

  constructor(private readonly service: AssetService) {}

  ngOnInit(): void {
    this.load();
  }

  load() {
    this.service.list().subscribe((a) => (this.assets = a));
  }
}
