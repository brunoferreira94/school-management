import { Component, OnInit } from "@angular/core";
import { FormBuilder, FormGroup } from "@angular/forms";
import { AssetService, AssetDto } from "../../services/asset.service";

@Component({
  selector: "app-asset-form",
  templateUrl: "./asset-form.component.html",
  standalone: true,
})
export class AssetFormComponent implements OnInit {
  form!: FormGroup;

  constructor(
    private readonly fb: FormBuilder,
    private readonly service: AssetService,
  ) {}

  ngOnInit(): void {
    this.form = this.fb.group({
      name: [""],
      tag: [""],
      category: [""],
      location: [""],
      notes: [""],
    });
  }

  save() {
    const payload = this.form.value as Partial<AssetDto>;
    this.service.create(payload).subscribe();
  }
}
