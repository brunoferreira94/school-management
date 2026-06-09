import { TestBed } from "@angular/core/testing";
import { AssetFormComponent } from "./asset-form.component";
import { AssetService } from "../../services/asset.service";
import { of } from "rxjs";

describe("AssetFormComponent", () => {
  beforeEach(async () => {
    const assetServiceStub = { create: () => of({}) } as Partial<AssetService>;

    await TestBed.configureTestingModule({
      imports: [AssetFormComponent],
      providers: [{ provide: AssetService, useValue: assetServiceStub }],
    }).compileComponents();
  });

  it("should create component", () => {
    const fixture = TestBed.createComponent(AssetFormComponent);
    const comp = fixture.componentInstance;
    expect(comp).toBeTruthy();
  });
});
